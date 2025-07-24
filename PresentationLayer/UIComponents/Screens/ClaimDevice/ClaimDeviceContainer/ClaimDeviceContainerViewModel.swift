//
//  ClaimDeviceContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/4/24.
//

import Foundation
import DomainLayer
import Combine
import Toolkit
import SwiftUI

@MainActor
class ClaimDeviceContainerViewModel: ObservableObject {
	@Published var selectedIndex: Int = 0
	@Published var isMovingNext = true
	@Published var showLoading = false
	@Published var loadingState: ClaimDeviceProgressView.State = .loading(.init(title: "", subtitle: ""))

	var steps: [ClaimDeviceStep] = []
	var navigationTitle: String = ""
	let useCase: MeUseCaseApi
	let devicesUseCase: DevicesUseCaseApi
	let deviceLocationUseCase: DeviceLocationUseCaseApi
	let photoGalleryUseCase: PhotoGalleryUseCaseApi
	var claimingKey: String?
	var serialNumber: String?
	var location: DeviceLocation?
	let photosManager: ClaimDevicePhotosManager = .shared
	var photos: [GalleryView.GalleryImage]? {
		guard let serialNumber else {
			return nil
		}

		return photosManager.getPhotos(for: serialNumber)
	}
	weak var photosViewModel: ClaimDevicePhotoViewModel?

	private let CLAIMING_RETRIES_MAX = 25 // For 2 minutes timeout
	private let CLAIMING_RETRIES_DELAY_SECONDS: TimeInterval = 5
	private var cancellableSet: Set<AnyCancellable> = .init()

	init(useCase: MeUseCaseApi,
		 devicesUseCase: DevicesUseCaseApi,
		 deviceLocationUseCase: DeviceLocationUseCaseApi,
		 photoGalleryUseCase: PhotoGalleryUseCaseApi) {
		self.useCase = useCase
		self.devicesUseCase = devicesUseCase
		self.deviceLocationUseCase = deviceLocationUseCase
		self.photoGalleryUseCase = photoGalleryUseCase
	}

	func viewAppeared() {}

	func moveNext() {
		isMovingNext = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.selectedIndex += 1
		}
	}

	func movePrevious() {
		isMovingNext = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.selectedIndex -= 1
		}
	}

	func handleSeriaNumber(serialNumber: ClaimDeviceSerialNumberViewModel.SerialNumber?) {
		guard let serialNumber else {
			moveNext()
			return
		}
		self.claimingKey = serialNumber.key
		self.serialNumber = serialNumber.serialNumber
		// Moving straight to last step
		guard let index = steps.firstIndex(where: {
			if case .location = $0 {
				return true
			}
			return false
		}), selectedIndex != index else {
			return
		}
		moveTo(index: index)
	}
}

extension ClaimDeviceContainerViewModel {
	func moveTo(index: Int) {
		isMovingNext = index > selectedIndex
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.selectedIndex = index
		}
	}

	func handleSNInputFields(fields: [InputFieldResult]) {
		fields.forEach { field in
			switch field.type {
				case .claimingKey:
					self.claimingKey = field.value
				case .serialNumber:
					self.serialNumber = field.value
			}
		}

		moveNext()

		if let serialNumber,
		   let images = photosManager.getPhotos(for: serialNumber) {
			photosViewModel?.updateImages(images)
		}
	}

	func performClaim(retries: Int? = nil) {
		guard let serialNumber = serialNumber?.replacingOccurrences(of: ":", with: ""),
			  let location else {
			return
		}
		do {
			let claimDeviceBody = ClaimDeviceBody(serialNumber: serialNumber,
												  location: location.coordinates.toCLLocationCoordinate2D(),
												  secret: claimingKey)
			loadingState = getLoadingState()
			showLoading = true

			try useCase.claimDevice(claimDeviceBody: claimDeviceBody)
				.sink { [weak self] response in
					guard let self = self else { return }

					switch response {
						case.failure(let responseError):
							if responseError.backendError?.code == FailAPICodeEnum.deviceClaiming.rawValue,
							   let retries,
							   retries < self.CLAIMING_RETRIES_MAX {
								print("Claiming Failed with \(responseError). Retrying after 5 seconds...")

								DispatchQueue.main.asyncAfter(deadline: .now() + self.CLAIMING_RETRIES_DELAY_SECONDS) {
									self.performClaim(retries: retries + 1)
								}

								return
							}

							let object = getFailObject(for: responseError)
							self.loadingState = .fail(object)
							WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .claimingResult,
																					  .success: .custom("0")])

							// Uncomment the following for testing
							/*
							Task { @MainActor in
								await startPhotoUpload(deviceId: "{station-device-id}")
							}
							 */
						case .success(let deviceResponse):
							print(deviceResponse)
							Task { @MainActor in
								var followState: UserDeviceFollowState?
								if let deviceId = deviceResponse.id {
									followState = try? await self.useCase.getDeviceFollowState(deviceId: deviceId).get()
									await self.startPhotoUpload(deviceId: deviceId)
								}

								let object = self.getSuccessObject(for: deviceResponse, followState: followState)
								self.loadingState = .success(object)
								WXMAnalytics.shared.trackEvent(.viewContent, parameters: [.contentName: .claimingResult,
																						  .success: .custom("1")])
							}
					}
				}
				.store(in: &cancellableSet)
		} catch {
			print(error)
		}
	}

	func startPhotoUpload(deviceId: String) async {
		guard let photos = photos else {
			return
		}

		do {
			try self.photoGalleryUseCase.clearLocalImages(deviceId: deviceId)
			let fileUrls = await photos.asyncMainActorCompactMap { try? await photoGalleryUseCase.saveImage($0.uiImage!,
																											deviceId: deviceId,
																											metadata: $0.metadata,
																											userComment: $0.source?.sourceValue ?? "")}
			try await self.photoGalleryUseCase.startFilesUpload(deviceId: deviceId, files: fileUrls.compactMap { try? $0.asURL() })
		} catch {
			Toast.shared.show(text: error.localizedDescription.attributedMarkdown ?? "")
		}
	}

	func getFailObject(for networkError: NetworkErrorResponse) -> FailSuccessStateObject {
		let uiInfo = networkError.uiInfo
		let object = FailSuccessStateObject(type: .claimDeviceFlow,
											title: uiInfo.title,
											subtitle: uiInfo.description?.attributedMarkdown,
											cancelTitle: LocalizableString.ClaimDevice.cancelClaimButton.localized,
											retryTitle: LocalizableString.ClaimDevice.retryClaimButton.localized,
											contactSupportAction: {
			LinkNavigationHelper().openContactSupport(successFailureEnum: .claimDeviceFlow, email: MainScreenViewModel.shared.userInfo?.email)
		}, cancelAction: {
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .claimingResult,
																	 .contentType: .claiming,
																	 .action: .cancel])

			Router.shared.popToRoot()
		}, retryAction: { [weak self] in
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .claimingResult,
																	 .contentType: .claiming,
																	 .action: .retry])
			self?.performClaim()
		})

		return object
	}

	func getSuccessObject(for device: DeviceDetails, followState: UserDeviceFollowState?) -> FailSuccessStateObject {
		let needsUpdate = device.needsUpdate(mainVM: MainScreenViewModel.shared, followState: followState) == true
		let retryTitle: String? = LocalizableString.ClaimDevice.viewStationButton.localized
		let goToStationAction: VoidCallback = { [weak self] in
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .claimingResult,
																	 .contentType: .claiming,
																	 .action: .viewStation])
			self?.dismissAndNavigate(device: device)
		}

		let updateFirmwareButton = Button(action: { [weak self] in
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .claimingResult,
																	 .contentType: .claiming,
																	 .action: .updateStation])

			self?.dismissAndNavigate(device: nil)
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // The only way found to avoid errors with navigation stack
				MainScreenViewModel.shared.showFirmwareUpdate(device: device)
			}
		}, label: {
			HStack(spacing: CGFloat(.smallSpacing)) {
				Text(FontIcon.sparkles.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))

				HStack {
					Spacer()
					Text(LocalizableString.ClaimDevice.updateFirmwareAlertTitle.localized)
					Spacer()
				}
			}
			.padding(.horizontal, CGFloat(.defaultSidePadding))
		}).buttonStyle(WXMButtonStyle.filled()).toAnyView

		let info: CardWarningConfiguration =  .init(type: .info,
													message: LocalizableString.ClaimDevice.updateFirmwareInfoMarkdown.localized,
													showBorder: true,
													closeAction: nil)
		let infoAppearAction = {
			WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .OTAAvailable,
																 .promptType: .warnPromptType,
																 .action: .viewAction])
		}

		let object = FailSuccessStateObject(type: .claimDeviceFlow,
											title: LocalizableString.ClaimDevice.successTitle.localized,
											subtitle: LocalizableString.ClaimDevice.successText(device.displayName).localized.attributedMarkdown,
											info: needsUpdate ? info : nil,
											infoCustomView: needsUpdate ? updateFirmwareButton : nil,
											infoOnAppearAction: needsUpdate ? infoAppearAction : nil,											
											cancelTitle: nil,
											retryTitle: retryTitle,
											actionButtonsLayout: .vertical,
											contactSupportAction: nil,
											cancelAction: nil,
											retryAction: goToStationAction)

		return object
	}

	func getLoadingState() -> ClaimDeviceProgressView.State {
		.loading(.init(title: LocalizableString.ClaimDevice.claimingTitle.localized,
					   subtitle: LocalizableString.ClaimDevice.claimStationLoadingDescription.localized.attributedMarkdown ?? ""))
	}

	func dismissAndNavigate(device: DeviceDetails?) {
		Router.shared.popToRoot()

		guard let device else {
			return
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // The only way found to avoid errors with navigation stack
			let route = Route.stationDetails(ViewModelsFactory.getStationDetailsViewModel(deviceId: device.id ?? "",
																						  cellIndex: device.cellIndex,
																						  cellCenter: device.cellCenter?.toCLLocationCoordinate2D()))
			Router.shared.navigateTo(route)
		}
	}
}

extension ClaimDeviceContainerViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
	}
}

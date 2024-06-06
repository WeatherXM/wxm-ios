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

class ClaimDeviceContainerViewModel: ObservableObject {
	@Published var selectedIndex: Int = 0
	@Published var isMovingNext = true
	@Published var showLoading = false
	@Published var loadingState: ClaimDeviceProgressView.State = .loading(.init(title: "", subtitle: ""))

	var steps: [ClaimDeviceStep] = []
	var navigationTitle: String = ""
	let useCase: MeUseCase
	let devicesUseCase: DevicesUseCase
	let deviceLocationUseCase: DeviceLocationUseCase
	var claimingKey: String?
	var serialNumber: String?
	var location: DeviceLocation?

	private let CLAIMING_RETRIES_MAX = 25 // For 2 minutes timeout
	private let CLAIMING_RETRIES_DELAY_SECONDS: TimeInterval = 5
	private var cancellableSet: Set<AnyCancellable> = .init()

	init(useCase: MeUseCase, devicesUseCase: DevicesUseCase, deviceLocationUseCase: DeviceLocationUseCase) {
		self.useCase = useCase
		self.devicesUseCase = devicesUseCase
		self.deviceLocationUseCase = deviceLocationUseCase
	}

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
}

extension ClaimDeviceContainerViewModel {
	func moveTo(index: Int) {
		isMovingNext = index > selectedIndex
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.selectedIndex = index
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

	func handleSNInputFields(fields: [SerialNumberInputField]) {
		fields.forEach { field in
			switch field.type {
				case .claimingKey:
					self.claimingKey = field.value
				case .serialNumber:
					self.serialNumber = field.value
			}
		}

		moveNext()
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
						case .success(let deviceResponse):
							print(deviceResponse)
							Task { @MainActor in
								var followState: UserDeviceFollowState?
								if let deviceId = deviceResponse.id {
									followState = try? await self.useCase.getDeviceFollowState(deviceId: deviceId).get()
								}

								let object = self.getSuccessObject(for: deviceResponse, followState: followState)
								self.loadingState = .success(object)
							}
					}
				}
				.store(in: &cancellableSet)
		} catch {
			print(error)
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
			HelperFunctions().openContactSupport(successFailureEnum: .claimDeviceFlow, email: MainScreenViewModel.shared.userInfo?.email)
		}) {
			Router.shared.popToRoot()
		} retryAction: { [weak self] in
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .claimingResult,
																	 .contentType: .claiming,
																	 .action: .retry])

			self?.performClaim()
		}

		return object
	}

	func getSuccessObject(for device: DeviceDetails, followState: UserDeviceFollowState?) -> FailSuccessStateObject {
		let needsUpdate = device.needsUpdate(mainVM: MainScreenViewModel.shared, followState: followState) == true
		let cancelTitle: String? = needsUpdate ? LocalizableString.ClaimDevice.updateFirmwareAlertGoToStation.localized : nil
		let retryTitle: String? = needsUpdate ? LocalizableString.ClaimDevice.updateFirmwareAlertTitle.localized : LocalizableString.ClaimDevice.updateFirmwareAlertGoToStation.localized
		let goToStationAction: VoidCallback = { [weak self] in
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .claimingResult,
																	 .contentType: .claiming,
																	 .action: .viewStation])

			self?.dismissAndNavigate(device: device)
		}
		let updateFirmwareAction: VoidCallback = { [weak self] in
			self?.dismissAndNavigate(device: nil)
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // The only way found to avoid errors with navigation stack
				MainScreenViewModel.shared.showFirmwareUpdate(device: device)
			}
		}

		let info = LocalizableString.ClaimDevice.updateFirmwareInfoMarkdown.localized.attributedMarkdown
		let infoAppearAction = {
			WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .OTAAvailable,
														   .promptType: .warnPromptType,
														   .action: .viewAction])
		}

		let object = FailSuccessStateObject(type: .claimDeviceFlow,
											title: LocalizableString.ClaimDevice.successTitle.localized,
											subtitle: LocalizableString.ClaimDevice.successText(device.displayName).localized.attributedMarkdown,
											info: needsUpdate ? info : nil,
											infoOnAppearAction: needsUpdate ? infoAppearAction : nil,
											cancelTitle: cancelTitle,
											retryTitle: retryTitle,
											contactSupportAction: nil,
											cancelAction: needsUpdate ? goToStationAction : nil ,
											retryAction: needsUpdate ? updateFirmwareAction : goToStationAction)

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
	func hash(into hasher: inout Hasher) {
	}
}

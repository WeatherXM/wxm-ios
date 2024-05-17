//
//  ClaimDeviceContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/4/24.
//

import Foundation
import DomainLayer
import Combine

class ClaimDeviceContainerViewModel: ObservableObject {
	@Published var selectedIndex: Int = 0
	@Published var isMovingNext = true
	@Published var showLoading = false
	@Published var loadingState: ClaimDeviceProgressView.State = .loading("", "")

	var steps: [ClaimDeviceStep] = []
	let navigationTitle: String
	let useCase: MeUseCase
	
	private var claimingKey: String?
	private var serialNumber: String?
	private var location: DeviceLocation?
	private var cancellableSet: Set<AnyCancellable> = .init()

	init(type: ClaimStationType, useCase: MeUseCase) {
		navigationTitle = type.navigationTitle
		self.useCase = useCase
		steps = getSteps(for: type)
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

private extension ClaimDeviceContainerViewModel {
	func getSteps(for type: ClaimStationType) -> [ClaimDeviceStep] {
		switch type {
			case .m5:
				getM5Steps()
			case .d1:
				getD1Steps()
			case .helium:
				getHeliumSteps()
			case .pulse:
				getPulseSteps()
		}
	}

	func getM5Steps() -> [ClaimDeviceStep] {
		let beginViewModel = ViewModelsFactory.getClaimStationM5BeginViewModel { [weak self] in
			self?.moveNext()
		}

		let snViewModel = ViewModelsFactory.getClaimStationM5SNViewModel { [weak self] serialNumber in
			self?.handleSeriaNumber(serialNumber: serialNumber)
		}

		let manualSNViewModel = ViewModelsFactory.getManualSNM5ViewModel { [weak self] fields in
			self?.handleSNInputFields(fields: fields)
		}

		let locationViewModel = ViewModelsFactory.getClaimDeviceLocationViewModel { [weak self] location in
			self?.handleLocation(location: location)
		}

		return [.begin(beginViewModel), .serialNumber(snViewModel), .manualSerialNumber(manualSNViewModel), .location(locationViewModel)]
	}

	func getD1Steps() -> [ClaimDeviceStep] {
		let beginViewModel = ViewModelsFactory.getClaimStationBeginViewModel { [weak self] in
			self?.moveNext()
		}

		let snViewModel = ViewModelsFactory.getClaimStationSNViewModel { [weak self] serialNumber in
			self?.handleSeriaNumber(serialNumber: serialNumber)
		}

		let manualSNViewModel = ViewModelsFactory.getManualSNViewModel { [weak self] fields in
			self?.handleSNInputFields(fields: fields)
		}

		let locationViewModel = ViewModelsFactory.getClaimDeviceLocationViewModel { [weak self] location in
			self?.handleLocation(location: location)
		}

		return [.begin(beginViewModel), .serialNumber(snViewModel), .manualSerialNumber(manualSNViewModel), .location(locationViewModel)]
	}

	func getHeliumSteps() -> [ClaimDeviceStep] {
		[]
	}

	func getPulseSteps() -> [ClaimDeviceStep] {
		[]
	}

	func handleSeriaNumber(serialNumber: ClaimDeviceSerialNumberViewModel.SerialNumber?) {
		guard let serialNumber else {
			moveNext()
			return
		}
		self.claimingKey = serialNumber.key
		self.serialNumber = serialNumber.serialNumber
		moveNext()
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

	func handleLocation(location: DeviceLocation) {
		self.location = location

		performClaim()
	}

	func performClaim() {
		guard let serialNumber, let location else {
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
							let object = getFailObject(for: responseError)
							self.loadingState = .fail(object)
						case .success(let deviceResponse):
							print(deviceResponse)
							let object = self.getSuccessObject(for: deviceResponse)
							self.loadingState = .success(object)
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
			self?.performClaim()
		}

		return object
	}

	func getSuccessObject(for device: DeviceDetails) -> FailSuccessStateObject {
		let object = FailSuccessStateObject(type: .claimDeviceFlow,
											title: LocalizableString.ClaimDevice.successTitle.localized,
											subtitle: LocalizableString.ClaimDevice.successText(device.displayName).localized.attributedMarkdown,
											cancelTitle: nil,
											retryTitle: LocalizableString.ClaimDevice.updateFirmwareAlertGoToStation.localized,
											contactSupportAction: nil,
											cancelAction: nil) { [weak self] in
			self?.dismissAndNavigate(device: device)
		}

		return object
	}

	func getLoadingState() -> ClaimDeviceProgressView.State {
		.loading(LocalizableString.ClaimDevice.claimingTitle.localized,
				 LocalizableString.ClaimDevice.claimStationLoadingDescription.localized.attributedMarkdown ?? "")
	}

	func dismissAndNavigate(device: DeviceDetails) {
		Router.shared.popToRoot()
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

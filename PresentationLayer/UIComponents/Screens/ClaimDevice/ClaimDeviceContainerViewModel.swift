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
	let navigationTitle: String
	let useCase: MeUseCase
	let devicesUseCase: DevicesUseCase
	let deviceLocationUseCase: DeviceLocationUseCase

	private let CLAIMING_RETRIES_MAX = 25 // For 2 minutes timeout
	private let CLAIMING_RETRIES_DELAY_SECONDS: TimeInterval = 5
	private var btDevice: BTWXMDevice?
	private var claimingKey: String?
	private var serialNumber: String?
	private var location: DeviceLocation?
	private var heliumFrequency: Frequency?
	private var cancellableSet: Set<AnyCancellable> = .init()

	init(type: ClaimStationType, useCase: MeUseCase, devicesUseCase: DevicesUseCase, deviceLocationUseCase: DeviceLocationUseCase) {
		navigationTitle = type.navigationTitle
		self.useCase = useCase
		self.devicesUseCase = devicesUseCase
		self.deviceLocationUseCase = deviceLocationUseCase
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
	func moveTo(index: Int) {
		isMovingNext = index > selectedIndex
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.selectedIndex = index
		}
	}
	
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
			self?.location = location
			self?.performClaim()
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
			self?.location = location
			self?.performClaim()
		}

		return [.begin(beginViewModel), .serialNumber(snViewModel), .manualSerialNumber(manualSNViewModel), .location(locationViewModel)]
	}

	func getHeliumSteps() -> [ClaimDeviceStep] {
		let resetViewModel = ViewModelsFactory.getResetDeviceViewModel { [weak self] in
			self?.moveNext()
		}

		let selectDeviceViewModel = ViewModelsFactory.getSelectDeviceViewModel(useCase: devicesUseCase) { [weak self] (device, error) in
			guard let self else {
				return
			}

			if let error {
				let object = self.getFailObject(for: error) { [weak self] in
					self?.showLoading = false
				}
				self.loadingState = .fail(object)
				self.showLoading = true
			} else {
				self.btDevice = device
				self.moveNext()
			}
		}

		let setFrequencyViewModel = ViewModelsFactory.getClaimDeviceSetFrequncyViewModel { [weak self] frequency in
			self?.heliumFrequency = frequency
			self?.performHeliumClaim()
		}

		let locationViewModel = ViewModelsFactory.getClaimDeviceLocationViewModel { [weak self, weak setFrequencyViewModel] location in
			self?.location = location
			let selectedFrequency = location.getFrequencyFromCurrentLocationCountry(from: self?.deviceLocationUseCase.getCountryInfos())
			setFrequencyViewModel?.preSelectedFrequency = selectedFrequency
			setFrequencyViewModel?.selectedFrequency = selectedFrequency
			setFrequencyViewModel?.selectedLocation = location
			setFrequencyViewModel?.didSelectFrequencyFromLocation = true
			self?.moveNext()
		}


		return [.reset(resetViewModel), .selectDevice(selectDeviceViewModel), .location(locationViewModel), .setFrequency(setFrequencyViewModel)]
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
			self?.performClaim()
		}

		return object
	}

	func getFailObject(for btError: BluetoothHeliumError, retryAction: @escaping VoidCallback) -> FailSuccessStateObject {
		let uiInfo = btError.uiInfo
		let object = FailSuccessStateObject(type: .claimDeviceFlow,
											title: uiInfo.title,
											subtitle: uiInfo.description?.attributedMarkdown,
											cancelTitle: LocalizableString.ClaimDevice.cancelClaimButton.localized,
											retryTitle: LocalizableString.ClaimDevice.retryClaimButton.localized,
											contactSupportAction: {
			HelperFunctions().openContactSupport(successFailureEnum: .claimDeviceFlow, email: MainScreenViewModel.shared.userInfo?.email)
		}) {
			Router.shared.popToRoot()
		} retryAction: {
			retryAction()
		}

		return object
	}

	func getSuccessObject(for device: DeviceDetails, followState: UserDeviceFollowState?) -> FailSuccessStateObject {
		let needsUpdate = device.needsUpdate(mainVM: MainScreenViewModel.shared, followState: followState) == true
		let cancelTitle: String? = needsUpdate ? LocalizableString.ClaimDevice.updateFirmwareAlertGoToStation.localized : nil
		let retryTitle: String? = needsUpdate ? LocalizableString.ClaimDevice.updateFirmwareAlertTitle.localized : LocalizableString.ClaimDevice.updateFirmwareAlertGoToStation.localized
		let goToStationAction: VoidCallback = { [weak self] in
			self?.dismissAndNavigate(device: device)
		}
		let updateFirmwareAction: VoidCallback = { [weak self] in
			self?.dismissAndNavigate(device: nil)
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // The only way found to avoid errors with navigation stack
				MainScreenViewModel.shared.showFirmwareUpdate(device: device)
			}
		}

		let object = FailSuccessStateObject(type: .claimDeviceFlow,
											title: LocalizableString.ClaimDevice.successTitle.localized,
											subtitle: LocalizableString.ClaimDevice.successText(device.displayName).localized.attributedMarkdown,
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

	func performHeliumClaim() {
		guard let btDevice else {
			return
		}

		let title = LocalizableString.ClaimDevice.claimingTitle.localized
		let boldText = LocalizableString.ClaimDevice.claimingTextInformation.localized
		let subtitle = LocalizableString.ClaimDevice.claimingText(boldText).localized

		Task { @MainActor in
			var steps: [StepsView.Step] = HeliumSteps.allCases.map { .init(text: $0.description, isCompleted: false) }

			loadingState = .loading(.init(title: title,
										  subtitle: subtitle.attributedMarkdown,
										  steps: steps,
										  stepIndex: 0,
										  progress: nil))
			showLoading = true

			// Set frequency
			if let setFrequencyError = await setHeliumFrequency() {
				let failObj = self.getFailObject(for: setFrequencyError) { [weak self] in
					self?.showLoading = false
				}
				loadingState = .fail(failObj)

				return
			}

			steps[0].isCompleted = true

			// Reboot

			loadingState = .loading(.init(title: title,
										  subtitle: subtitle.attributedMarkdown,
										  steps: steps,
										  stepIndex: 1,
										  progress: nil))

			if let rebootError = await reboot() {
				let failObj = self.getFailObject(for: rebootError) { [weak self] in
					self?.showLoading = false
				}

				loadingState = .fail(failObj)

				return
			}

			steps[1].isCompleted = true

			// Fetch device info
			
			loadingState = .loading(.init(title: title,
										  subtitle: subtitle.attributedMarkdown,
										  steps: steps,
										  stepIndex: 2,
										  progress: nil))

			let result = await devicesUseCase.getDeviceInfo(device: btDevice)
			switch result {
				case .success(let info):
					// perform claim request
					self.serialNumber = info?.devEUI
					self.claimingKey = info?.claimingKey
					self.performClaim(retries: 0)
				case .failure(let error):
					let failObj = self.getFailObject(for: error) { [weak self] in
						self?.showLoading = false
					}
					loadingState = .fail(failObj)
			}
		}
	}

	func setHeliumFrequency() async -> BluetoothHeliumError? {
		guard let heliumFrequency, let btDevice else {
			return .unknown
		}

		let error = await devicesUseCase.setHeliumFrequency(btDevice, frequency: heliumFrequency)
		return error
	}

	func reboot() async -> BluetoothHeliumError? {
		guard let btDevice else {
			return .unknown
		}

		return await devicesUseCase.reboot(device: btDevice)
	}
}

extension ClaimDeviceContainerViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
	}
}

//
//  ClaimHeliumContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/6/24.
//

import Foundation
import DomainLayer
import Toolkit

@MainActor
class ClaimHeliumContainerViewModel: ClaimDeviceContainerViewModel {
	private var btDevice: BTWXMDevice?
	private var heliumFrequency: Frequency?

	override init(useCase: MeUseCase, devicesUseCase: DevicesUseCase, deviceLocationUseCase: DeviceLocationUseCase) {
		super.init(useCase: useCase, devicesUseCase: devicesUseCase, deviceLocationUseCase: deviceLocationUseCase)
		navigationTitle = ClaimStationType.helium.navigationTitle
		steps = getSteps()
	}
}

private extension ClaimHeliumContainerViewModel {
	func getSteps() -> [ClaimDeviceStep] {
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

			if let apiFrequencyError = await self.setApiHeliumFrequency() {
				let uiInfo = apiFrequencyError.uiInfo
				let failObj = uiInfo.defaultFailObject(type: .claimDeviceFlow, failMode: .retry) { [weak self] in
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

	func setApiHeliumFrequency() async -> NetworkErrorResponse? {
		guard let heliumFrequency, let serialNumber else {
			return nil
		}

		let error = try? await useCase.setFrequncy(serialNumber, frequency: heliumFrequency)
		return error
	}

	func reboot() async -> BluetoothHeliumError? {
		guard let btDevice else {
			return .unknown
		}

		return await devicesUseCase.reboot(device: btDevice)
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
		}, cancelAction: {
			Router.shared.popToRoot()
		}, retryAction: {
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .heliumBLEPopupError,
																	 .contentType: .heliumBLEPopup,
																	 .action: .tryAgain])

			retryAction()
		})

		return object
	}
}

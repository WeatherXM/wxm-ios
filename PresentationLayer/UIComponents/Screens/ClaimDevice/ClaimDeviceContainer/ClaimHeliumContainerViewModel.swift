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

	override init(useCase: MeUseCaseApi, devicesUseCase: DevicesUseCaseApi, deviceLocationUseCase: DeviceLocationUseCaseApi) {
		super.init(useCase: useCase, devicesUseCase: devicesUseCase, deviceLocationUseCase: deviceLocationUseCase)
		navigationTitle = ClaimStationType.helium.navigationTitle
		steps = getSteps()
	}

	override func viewAppeared() {
		WXMAnalytics.shared.trackScreen(.claimHelium)
	}
}

private extension ClaimHeliumContainerViewModel {
	func getSteps() -> [ClaimDeviceStep] {
		let beforeBeginViewModel = ViewModelsFactory.getClaimBeforeBeginViewModel { [weak self] in
			self?.moveNext()
		}

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
				WXMAnalytics.shared.trackScreen(.bleConnectionPopupError)
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

		return [.beforeBegin(beforeBeginViewModel),
				.reset(resetViewModel),
				.selectDevice(selectDeviceViewModel),
				.location(locationViewModel),
				.setFrequency(setFrequencyViewModel)]
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

			// Fetch device info
#if targetEnvironment(simulator)
			let result: Result<BTWXMDeviceInfo?, BluetoothHeliumError> = .success(.init(devEUI: "", claimingKey: ""))
#else
			let result = await devicesUseCase.getDeviceInfo(device: btDevice)
#endif
			switch result {
				case .success(let info):
					// perform claim request
					self.serialNumber = info?.devEUI
					self.claimingKey = info?.claimingKey
				case .failure(let error):
					let failObj = self.getFailObject(for: error) { [weak self] in
						self?.showLoading = false
					}
					loadingState = .fail(failObj)
					return
			}

			// Set frequency
			if let setFrequencyError = await setHeliumFrequency() {
				let failObj = self.getFailObject(for: setFrequencyError) { [weak self] in
					self?.showLoading = false
				}
				loadingState = .fail(failObj)

				return
			}

			do {
				if let apiFrequencyError = try await self.setApiHeliumFrequency() {
					let uiInfo = apiFrequencyError.uiInfo
					let failObj = uiInfo.defaultFailObject(type: .claimDeviceFlow, failMode: .default) { [weak self] in
						self?.showLoading = false
					}
					loadingState = .fail(failObj)
					return
				}
			} catch {
				let uiInfo = NetworkErrorResponse.UIInfo(title: LocalizableString.Error.genericMessage.localized,
														 description: nil)
				let failObj = uiInfo.defaultFailObject(type: .claimDeviceFlow, failMode: .default) { [weak self] in
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

			loadingState = .loading(.init(title: title,
										  subtitle: subtitle.attributedMarkdown,
										  steps: steps,
										  stepIndex: 2,
										  progress: nil))

			self.performClaim(retries: 0)
		}
	}

	func setHeliumFrequency() async -> BluetoothHeliumError? {
#if targetEnvironment(simulator)
		return nil
#endif
		guard let heliumFrequency, let btDevice else {
			return .unknown
		}

		let error = await devicesUseCase.setHeliumFrequency(btDevice, frequency: heliumFrequency)
		return error
	}

	func setApiHeliumFrequency() async throws -> NetworkErrorResponse? {
		guard let heliumFrequency, let serialNumber = serialNumber?.replacingOccurrences(of: ":", with: "") else {
			throw NSError(domain: "", code: -1)
		}

		let error = try? await useCase.setFrequency(serialNumber, frequency: heliumFrequency)
		return error
	}

	func reboot() async -> BluetoothHeliumError? {
#if targetEnvironment(simulator)
		return nil
#endif

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
			LinkNavigationHelper().openContactSupport(successFailureEnum: .claimDeviceFlow, email: MainScreenViewModel.shared.userInfo?.email)
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

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
			LoaderView.shared.show()

			try useCase.claimDevice(claimDeviceBody: claimDeviceBody)
				.sink { [weak self] response in
					LoaderView.shared.dismiss()

					guard let self = self else { return }


					switch response {
						case.failure(let responseError):
							if responseError.backendError?.code == FailAPICodeEnum.deviceClaiming.rawValue {
								// Still claiming.
//								self.claimWorkItem?.cancel()
//								let claimWorkItem = DispatchWorkItem { [weak self] in
//									self?.performPersistentClaimDeviceCall(retries: retries + 1)
//								}
//								self.claimWorkItem = claimWorkItem
//
//								DispatchQueue.main.asyncAfter(
//									deadline: .now() + Self.CLAIMING_RETRIES_DELAY_SECONDS,
//									execute: claimWorkItem
//								)

								return
							}
							Toast.shared.show(text: responseError.uiInfo.description?.attributedMarkdown ?? "")

						case .success(let deviceResponse):
							print(deviceResponse)
//							Task { @MainActor in
//								var followState: UserDeviceFollowState?
//								if let deviceId = deviceResponse.id {
//									followState = try? await self.meUseCase.getDeviceFollowState(deviceId: deviceId).get()
//								}
//								self.claimState = .success(deviceResponse, followState)
//							}
					}
				}
				.store(in: &cancellableSet)
		} catch {
			print(error)
		}
	}
}

extension ClaimDeviceContainerViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
	}
}

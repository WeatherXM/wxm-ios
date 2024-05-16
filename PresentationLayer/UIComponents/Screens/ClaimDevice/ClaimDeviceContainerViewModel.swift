//
//  ClaimDeviceContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/4/24.
//

import Foundation
import DomainLayer

class ClaimDeviceContainerViewModel: ObservableObject {
	@Published var selectedIndex: Int = 0
	@Published var isMovingNext = true

	var steps: [ClaimDeviceStep] = []
	let navigationTitle: String
	let useCase: MeUseCase
	
	private var claimingKey: String?
	private var serialNumber: String?
	private var location: DeviceLocation?

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
	}
}

extension ClaimDeviceContainerViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
	}
}

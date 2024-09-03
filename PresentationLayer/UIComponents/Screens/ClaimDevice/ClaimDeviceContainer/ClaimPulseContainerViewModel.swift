//
//  ClaimPulseContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/6/24.
//

import Foundation
import DomainLayer

class ClaimPulseContainerViewModel: ClaimDeviceContainerViewModel {

	override init(useCase: MeUseCase, devicesUseCase: DevicesUseCase, deviceLocationUseCase: DeviceLocationUseCase) {
		super.init(useCase: useCase, devicesUseCase: devicesUseCase, deviceLocationUseCase: deviceLocationUseCase)
		navigationTitle = ClaimStationType.pulse.navigationTitle
		steps = getSteps()
	}

	override func handleSeriaNumber(serialNumber: ClaimDeviceSerialNumberViewModel.SerialNumber?) {
		guard let serial = serialNumber?.serialNumber else {
			moveNext()
			return
		}

		self.serialNumber = serial
		
		let index = min(selectedIndex + 2, steps.count - 1)
		moveTo(index: index)
	}
}

private extension ClaimPulseContainerViewModel {
	func getSteps() -> [ClaimDeviceStep] {
		let resetViewModel = ViewModelsFactory.getResetPulseViewModel { [weak self] in
			self?.moveNext()
		}

		let serialNumberViewModel = ViewModelsFactory.getClaimStationPulseSNViewModel { serialNumber in
			self.handleSeriaNumber(serialNumber: serialNumber)
		}

		let manualSNViewModel = ViewModelsFactory.getManualSNPulseViewModel { [weak self] fields in
			self?.handleSNInputFields(fields: fields)
		}

		let claimingKeyViewModel = ViewModelsFactory.getClaimingKeyPulseViewModel { [weak self] fields in
			self?.handleSNInputFields(fields: fields)
		}

		let locationViewModel = ViewModelsFactory.getClaimDeviceLocationViewModel { [weak self] location in
			self?.location = location
			self?.performClaim()
		}

		return [.reset(resetViewModel), .serialNumber(serialNumberViewModel),
				.manualSerialNumber(manualSNViewModel),
				.manualSerialNumber(claimingKeyViewModel),
				.location(locationViewModel)]
	}
}

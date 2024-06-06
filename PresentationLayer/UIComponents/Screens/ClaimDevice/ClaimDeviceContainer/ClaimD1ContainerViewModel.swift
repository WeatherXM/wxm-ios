//
//  ClaimD1ContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/6/24.
//

import Foundation
import DomainLayer

class ClaimD1ContainerViewModel: ClaimDeviceContainerViewModel {
	override init(useCase: MeUseCase, devicesUseCase: DevicesUseCase, deviceLocationUseCase: DeviceLocationUseCase) {
		super.init(useCase: useCase, devicesUseCase: devicesUseCase, deviceLocationUseCase: deviceLocationUseCase)
		navigationTitle = ClaimStationType.d1.navigationTitle
		steps = getSteps()
	}
}

private extension ClaimD1ContainerViewModel {
	func getSteps() -> [ClaimDeviceStep] {
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
}

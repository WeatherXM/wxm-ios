//
//  ClaimD1ContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/6/24.
//

import Foundation
import DomainLayer
import Toolkit

class ClaimD1ContainerViewModel: ClaimDeviceContainerViewModel {
	override init(useCase: MeUseCaseApi, devicesUseCase: DevicesUseCaseApi, deviceLocationUseCase: DeviceLocationUseCaseApi) {
		super.init(useCase: useCase, devicesUseCase: devicesUseCase, deviceLocationUseCase: deviceLocationUseCase)
		navigationTitle = ClaimStationType.d1.navigationTitle
		steps = getSteps()
	}

	override func viewAppeared() {
		WXMAnalytics.shared.trackScreen(.claimD1)
	}
}

private extension ClaimD1ContainerViewModel {
	func getSteps() -> [ClaimDeviceStep] {
		let beforeBeginViewModel = ViewModelsFactory.getClaimBeforeBeginViewModel { [weak self] in
			self?.moveNext()
		}

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
		}

		let photoIntroViewModel = ViewModelsFactory.getClaimDevicePhotoViewModel { [weak self] in
			self?.moveNext()
			self?.performClaim(retries: 0)
		}

		return [.beforeBegin(beforeBeginViewModel),
				.begin(beginViewModel),
				.serialNumber(snViewModel),
				.manualSerialNumber(manualSNViewModel),
				.location(locationViewModel),
				.photoIntro(photoIntroViewModel)]
	}
}

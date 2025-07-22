//
//  ClaimPulseContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/6/24.
//

import Foundation
import DomainLayer
import Toolkit

class ClaimPulseContainerViewModel: ClaimDeviceContainerViewModel {

	override init(useCase: MeUseCaseApi,
				  devicesUseCase: DevicesUseCaseApi,
				  deviceLocationUseCase: DeviceLocationUseCaseApi,
				  photoGalleryUseCase: PhotoGalleryUseCaseApi) {
		super.init(useCase: useCase,
				   devicesUseCase: devicesUseCase,
				   deviceLocationUseCase: deviceLocationUseCase,
				   photoGalleryUseCase: photoGalleryUseCase)
		navigationTitle = ClaimStationType.pulse.navigationTitle
		steps = getSteps()
	}

	override func viewAppeared() {
		WXMAnalytics.shared.trackScreen(.claimPulse)
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
		let beforeBeginViewModel = ViewModelsFactory.getClaimBeforeBeginViewModel { [weak self] in
			self?.moveNext()
		}

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
		}

		let photoIntroViewModel = ViewModelsFactory.getClaimDevicePhotoViewModel { [weak self] in
			self?.moveNext()
		}

		let photoViewModel = ViewModelsFactory.getClaimDevicePhotoGalleryViewModel(linkNavigator: LinkNavigationHelper()) { [weak self] photos in
			self?.photos = photos
			self?.performClaim()
		}

		return [.beforeBegin(beforeBeginViewModel),
				.reset(resetViewModel),
				.serialNumber(serialNumberViewModel),
				.manualSerialNumber(manualSNViewModel),
				.manualSerialNumber(claimingKeyViewModel),
				.location(locationViewModel),
				.photoIntro(photoIntroViewModel),
				.photos(photoViewModel)]
	}
}

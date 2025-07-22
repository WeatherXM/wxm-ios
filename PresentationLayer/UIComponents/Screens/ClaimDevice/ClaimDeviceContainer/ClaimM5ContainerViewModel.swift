//
//  ClaimM5ContainerViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/6/24.
//

import Foundation
import DomainLayer
import Toolkit

class ClaimM5ContainerViewModel: ClaimDeviceContainerViewModel {
	
	override init(useCase: MeUseCaseApi,
				  devicesUseCase: DevicesUseCaseApi,
				  deviceLocationUseCase: DeviceLocationUseCaseApi,
				  photoGalleryUseCase: PhotoGalleryUseCaseApi) {
		super.init(useCase: useCase,
				   devicesUseCase: devicesUseCase,
				   deviceLocationUseCase: deviceLocationUseCase,
				   photoGalleryUseCase: photoGalleryUseCase)
		navigationTitle = ClaimStationType.m5.navigationTitle
		steps = getSteps()
	}

	override func viewAppeared() {
		WXMAnalytics.shared.trackScreen(.claimM5)
	}
}

private extension ClaimM5ContainerViewModel {
	func getSteps() -> [ClaimDeviceStep] {
		let beforeBeginViewModel = ViewModelsFactory.getClaimBeforeBeginViewModel { [weak self] in
			self?.moveNext()
		}

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
			self?.moveNext()
		}

		let photoIntroViewModel = ViewModelsFactory.getClaimDevicePhotoViewModel { [weak self] in
			self?.moveNext()
		}

		let photoViewModel = ViewModelsFactory.getClaimDevicePhotoGalleryViewModel(linkNavigator: LinkNavigationHelper()) { [weak self] photos in
			self?.photos = photos
			self?.performClaim()
		}

		return [.beforeBegin(beforeBeginViewModel),
				.begin(beginViewModel),
				.serialNumber(snViewModel),
				.manualSerialNumber(manualSNViewModel),
				.location(locationViewModel),
				.photoIntro(photoIntroViewModel),
				.photos(photoViewModel)]
	}
}

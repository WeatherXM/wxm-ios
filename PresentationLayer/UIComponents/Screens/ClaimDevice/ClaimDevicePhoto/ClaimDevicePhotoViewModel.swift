//
//  ClaimDevicePhotoViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/7/25.
//

import Foundation
import DomainLayer
import Toolkit

@MainActor
class ClaimDevicePhotoViewModel: ObservableObject {
	let photosViewModel: GalleryImagesViewModel
	var completion: GenericCallback<[GalleryView.GalleryImage]>?

	private let minPhotosCount = 2

	init(useCase: PhotoGalleryUseCaseApi, linkNavigator: LinkNavigation) {
		photosViewModel = ViewModelsFactory.getClaimGalleryImagesViewModel(images: [], linkNavigator: linkNavigator)
		photosViewModel.delegate = self
	}

	var ctaButtonText: String {
		LocalizableString.ClaimDevice.uploadAndClaim.localized
	}

	var isCtaButtonEnabled: Bool {
		photosViewModel.images.count >= minPhotosCount
	}

	func updateImages(_ images: [GalleryView.GalleryImage]) {
		photosViewModel.images = images
		photosViewModel.selectedImage = images.last
	}

	func handleCtaButtonTap() {
		completion?(photosViewModel.images)
	}
}

extension ClaimDevicePhotoViewModel: GalleryImagesViewModelDelegate {
	func handleDeleteButtonTap(for image: GalleryView.GalleryImage) async -> Bool {
		photosViewModel.images.removeAll(where: { $0 == image })
		return true
	}
}

@MainActor
class ClaimHeliumPhotoViewModel: ClaimDevicePhotoViewModel {
	override var ctaButtonText: String {
		LocalizableString.ClaimDevice.uploadAndProceed.localized
	}
}

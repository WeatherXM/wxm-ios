//
//  ClaimDevicePhotoViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/7/25.
//

import Foundation
import DomainLayer

@MainActor
class ClaimDevicePhotoViewModel: ObservableObject {
	let photosViewModel: GalleryImagesViewModel

	init(useCase: PhotoGalleryUseCaseApi, linkNavigator: LinkNavigation) {
		photosViewModel = ViewModelsFactory.getGalleryImagesViewModel(images: [], linkNavigator: linkNavigator)
		photosViewModel.delegate = self
	}
}

extension ClaimDevicePhotoViewModel: GalleryImagesViewModelDelegate {
	func handleDeleteButtonTap(for image: GalleryView.GalleryImage) async -> Bool {
		photosViewModel.images.removeAll(where: { $0 == image })
		return true
	}
}

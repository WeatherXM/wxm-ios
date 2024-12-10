//
//  GalleryViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/12/24.
//

import Foundation
import UIKit
import DomainLayer

@MainActor
class GalleryViewModel: ObservableObject {
	@Published var subtitle: String? = ""
	@Published var images: [String] = ["https://weatherxm.s3.eu-west-1.amazonaws.com/resources/public/BetaRewardsBoostImg.png"]

	private let useCase: PhotoGalleryUseCase
	private lazy var imagePickerDelegate = {
		let picker = ImagePickerDelegate(useCase: useCase)
		picker.imageCallback = { [weak self] imageUrl in
			self?.images.append(imageUrl)
		}
		return picker
	}()

	init(photoGalleryUseCase: PhotoGalleryUseCase) {
		self.useCase = photoGalleryUseCase
		updateSubtitle()
	}

	func handlePlusButtonTap() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .camera
		imagePicker.allowsEditing = true
		imagePicker.delegate = imagePickerDelegate
		UIApplication.shared.topViewController?.present(imagePicker, animated: true)
	}
}

extension GalleryViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
	}
}

private class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	var imageCallback: ((String) -> Void)?
	private let useCase: PhotoGalleryUseCase

	init(useCase: PhotoGalleryUseCase) {
		self.useCase = useCase
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let image = info[.editedImage] as? UIImage,
		   let imageUrl = try? useCase.saveImage(image) {
			imageCallback?(imageUrl)
		}

		picker.dismiss(animated: true)
	}
}

private extension GalleryViewModel {
	func updateSubtitle() {
		subtitle = LocalizableString.PhotoVerification.morePhotosToUpload(2).localized
	}
}

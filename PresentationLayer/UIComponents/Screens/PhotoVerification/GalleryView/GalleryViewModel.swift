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
	@Published var images: [String] = ["https://i0.wp.com/weatherxm.com/wp-content/uploads/2023/09/5-5.png"]
	@Published var selectedImage: String?
	@Published var showInstructions: Bool = false

	private let useCase: PhotoGalleryUseCase
	private lazy var imagePickerDelegate = {
		let picker = ImagePickerDelegate(useCase: useCase)
		picker.imageCallback = { [weak self] imageUrl in
			self?.images.insert(imageUrl, at: 0)
			self?.selectedImage = self?.images.first
		}
		return picker
	}()

	init(photoGalleryUseCase: PhotoGalleryUseCase) {
		self.useCase = photoGalleryUseCase
		updateSubtitle()
		selectedImage = images.first
	}

	func handlePlusButtonTap() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .camera
		imagePicker.allowsEditing = true
		imagePicker.delegate = imagePickerDelegate
		UIApplication.shared.topViewController?.present(imagePicker, animated: true)
	}

	func handleDeleteButtonTap() {
		guard let selectedImage else {
			return
		}

		do {
			try useCase.deleteImage(selectedImage)
			images.removeAll(where: { $0 == selectedImage })
			self.selectedImage = images.first
		} catch {
			Toast.shared.show(text: error.localizedDescription.attributedMarkdown ?? "")
		}
	}

	func handleInstructionsButtonTap() {
		showInstructions = true
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

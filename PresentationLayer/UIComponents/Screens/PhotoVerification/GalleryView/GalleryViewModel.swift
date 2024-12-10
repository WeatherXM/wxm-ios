//
//  GalleryViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/12/24.
//

import Foundation
import UIKit

@MainActor
class GalleryViewModel: ObservableObject {
	@Published var subtitle: String? = ""
	@Published var images: [String] = ["https://weatherxm.s3.eu-west-1.amazonaws.com/resources/public/BetaRewardsBoostImg.png"]

	private lazy var imagePickerDelegate = {
		let picker = ImagePickerDelegate()
		picker.imageCallback = { [weak self] imageUrl in
			self?.images.append(imageUrl)
		}
		return picker
	}()

	init() {
		updateSubtitle()
	}

	func handlePlusButtonTap() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .camera
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

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let imageUrl = info[.imageURL] as? String {
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

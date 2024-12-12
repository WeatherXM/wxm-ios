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
	@Published var images: [String] = [] {
		didSet {
			updateSubtitle()
		}
	}
	@Published var selectedImage: String?
	@Published var isCameraDenied: Bool = false
	@Published var showInstructions: Bool = false
	var isPlusButtonVisible: Bool {
		images.count < maxPhotosCount
	}
	var isPlusButtonEnabled: Bool {
		useCase.getCameraPermission() != .denied
	}
	var isUploadButtonEnabled: Bool {
		images.count >= minPhotosCount
	}
	private let minPhotosCount = 2
	private let maxPhotosCount = 6
	private let useCase: PhotoGalleryUseCase
	private lazy var imagePickerDelegate = {
		let picker = ImagePickerDelegate(useCase: useCase)
		picker.imageCallback = { [weak self] imageUrl in
			self?.images.append(imageUrl)
			self?.selectedImage = self?.images.last
		}
		return picker
	}()

	init(photoGalleryUseCase: PhotoGalleryUseCase) {
		self.useCase = photoGalleryUseCase
		selectedImage = images.last
		updateSubtitle()
		updateCameraPermissionState()
	}

	func handlePlusButtonTap() {
		let openPikerCallback = { @MainActor [weak self] in
			guard let self else { return }
			let imagePicker = UIImagePickerController()
			imagePicker.sourceType = .camera
			imagePicker.delegate = self.imagePickerDelegate
			UIApplication.shared.topViewController?.present(imagePicker, animated: true)
		}

		// If permission is authorized, we open the camera
		let permission = useCase.getCameraPermission()
		if permission == .authorized {
			openPikerCallback()
			return
		}

		// If not, we request permission and then present the camera picker
		Task { @MainActor in
			let permission = await useCase.requestCameraPermission()
			updateCameraPermissionState()
			guard permission == .authorized else {
				return
			}

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: openPikerCallback)
		}
	}

	func handleDeleteButtonTap() {
		guard let selectedImage else {
			return
		}

		do {
			try useCase.deleteImage(selectedImage)
			images.removeAll(where: { $0 == selectedImage })
			self.selectedImage = images.last
		} catch {
			Toast.shared.show(text: error.localizedDescription.attributedMarkdown ?? "")
		}
	}

	func handleInstructionsButtonTap() {
		showInstructions = true
	}

	func handleUploadButtonTap() {
		
	}

	func handleOpenSettingsTap() {
		guard let url = URL(string: UIApplication.openSettingsURLString) else {
			return
		}

		UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
		if let image = info[.originalImage] as? UIImage,
		   let imageUrl = try? useCase.saveImage(image) {
			imageCallback?(imageUrl)
		}

		picker.dismiss(animated: true)
	}
}

private extension GalleryViewModel {
	func updateSubtitle() {
		let remainingCount = minPhotosCount - images.count
		if remainingCount > 0 {
			subtitle = LocalizableString.PhotoVerification.morePhotosToUpload(remainingCount).localized
		} else {
			subtitle = nil
		}
	}

	func updateCameraPermissionState() {
		let status = useCase.getCameraPermission()
		switch status {
			case .notDetermined, .authorized:
				isCameraDenied = false
			case .restricted, .denied:
				isCameraDenied = true
			@unknown default:
				isCameraDenied = true
		}
	}
}

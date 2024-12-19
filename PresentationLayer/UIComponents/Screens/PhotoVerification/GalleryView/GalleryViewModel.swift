//
//  GalleryViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/12/24.
//

import Foundation
import UIKit
import DomainLayer
import SwiftUI

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
	@Published var showShareSheet: Bool = false
	var shareFileUrls: [URL]? {
		images.compactMap { try? $0.asURL() }
	}
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

	init(images: [String], photoGalleryUseCase: PhotoGalleryUseCase) {
		self.useCase = photoGalleryUseCase
		self.images = images
		selectedImage = images.last
		updateSubtitle()
		updateCameraPermissionState()
	}

	func handlePlusButtonTap() {
		openCamera()
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
		// TEMP
		showShareSheet = true
	}

	func handleOpenSettingsTap() {
		guard let url = URL(string: UIApplication.openSettingsURLString) else {
			return
		}

		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

	func viewLoaded() {
		openCamera()
	}

	func handleBackButtonTap(dismissAction: DismissAction) {
		let remoteImageCount = images.compactMap { URL(string: $0) }.filter { $0.isHttp }.count
		let message = remoteImageCount == 1 ? LocalizableString.PhotoVerification.exitPhotoVerificationMinimumPhotosText.localized : LocalizableString.PhotoVerification.exitPhotoVerificationText.localized

		let exitAction: AlertHelper.AlertObject.Action = (LocalizableString.exit.localized, { _ in  dismissAction() })
		let alertObject = AlertHelper.AlertObject(title: LocalizableString.PhotoVerification.exitPhotoVerification.localized,
												  message: message,
												  cancelActionTitle: LocalizableString.back.localized,
												  cancelAction: {},
												  okAction: exitAction)

		AlertHelper().showAlert(alertObject)
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
		let metadata = info[.mediaMetadata] as? NSDictionary
		Task { @MainActor in
			if let image = info[.originalImage] as? UIImage,
			   let imageUrl = try? await useCase.saveImage(image, metadata: metadata) {
				imageCallback?(imageUrl)
			}
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

	func openCamera() {
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
}

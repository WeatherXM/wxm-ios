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
	var backButtonIcon: FontIcon {
		if isNewPhotoVerification {
			return .xmark
		}

		return .arrowLeft
	}
	private let minPhotosCount = 2
	private let maxPhotosCount = 6
	let deviceId: String
	private let useCase: PhotoGalleryUseCase
	private let isNewPhotoVerification: Bool
	private lazy var imagePickerDelegate = {
		let picker = ImagePickerDelegate(useCase: useCase)
		picker.imageCallback = { [weak self] imageUrl in
			self?.images.append(imageUrl)
			self?.selectedImage = self?.images.last
		}
		return picker
	}()

	init(deviceId: String,
		 images: [String],
		 photoGalleryUseCase: PhotoGalleryUseCase,
		 isNewPhotoVerification: Bool) {
		self.deviceId = deviceId
		self.useCase = photoGalleryUseCase
		self.images = images
		self.isNewPhotoVerification = isNewPhotoVerification
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

		Task { @MainActor in
			do {
				try await useCase.deleteImage(selectedImage, deviceId: deviceId)
				images.removeAll(where: { $0 == selectedImage })
				self.selectedImage = images.last
			} catch PhotosError.networkError(let error) {
				let info = error.uiInfo
				if let message = info.description?.attributedMarkdown {
					Toast.shared.show(text: message)
				}
			}
			catch {
				Toast.shared.show(text: error.localizedDescription.attributedMarkdown ?? "")
			}
		}
	}

	func handleInstructionsButtonTap() {
		showInstructions = true
	}

	func handleUploadButtonTap() {
		guard let fileUrls = shareFileUrls?.filter({ $0.isFileURL }) else {
			return
		}
		Task { @MainActor in
			do {
				try await useCase.startFilesUpload(deviceId: deviceId, files: fileUrls)
			} catch PhotosError.networkError(let error) {
				let info = error.uiInfo
				if let message = info.description?.attributedMarkdown {
					Toast.shared.show(text: message)
				}
			}
			catch {
				Toast.shared.show(text: error.localizedDescription.attributedMarkdown ?? "")
			}
		}
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
		if isNewPhotoVerification {
			showExitAlert(message: LocalizableString.PhotoVerification.exitPhotoVerificationText.localized,
						  dismissAction: dismissAction)

			return
		}

		let remoteImageCount = images.compactMap { URL(string: $0) }.filter { $0.isHttp }.count
		if remoteImageCount < minPhotosCount {
			showExitAlert(message: LocalizableString.PhotoVerification.exitPhotoVerificationMinimumPhotosText.localized,
						  dismissAction: dismissAction)
			
			return
		}

		dismissAction()
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

	func showExitAlert(message: String, dismissAction: DismissAction) {
		let exitAction: AlertHelper.AlertObject.Action = (LocalizableString.exit.localized, { _ in  dismissAction() })
		let alertObject = AlertHelper.AlertObject(title: LocalizableString.PhotoVerification.exitPhotoVerification.localized,
												  message: message,
												  cancelActionTitle: LocalizableString.back.localized,
												  cancelAction: {},
												  okAction: exitAction)

		AlertHelper().showAlert(alertObject)
	}
}

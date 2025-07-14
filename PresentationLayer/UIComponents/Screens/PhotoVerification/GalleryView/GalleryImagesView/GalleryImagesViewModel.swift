//
//  GalleryImagesViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/7/25.
//

import Foundation
import UIKit
import DomainLayer
import SwiftUI
import Toolkit
@preconcurrency import PhotosUI

private enum PickerType {
	case camera
	case photoLibrary

	var parameterValue: ParameterValue {
		switch self {
			case .camera:
				return .camera
			case .photoLibrary:
				return .gallery
		}
	}
}

@MainActor
protocol GalleryImagesViewModelDelegate: AnyObject, Sendable {
	func handleDeleteButtonTap(for image: GalleryView.GalleryImage) async -> Bool
}

@MainActor
class GalleryImagesViewModel: ObservableObject {
	@Published var images: [GalleryView.GalleryImage] = []
	@Published var selectedImage: GalleryView.GalleryImage?
	@Published var isCameraDenied: Bool = false
	@Published var showInstructions: Bool = false
	var isPlusButtonEnabled: Bool {
		useCase.getCameraPermission() != .denied
	}
	weak var delegate: GalleryImagesViewModelDelegate?

	private let useCase: PhotoGalleryUseCaseApi
	private let linkNavigator: LinkNavigation

	private let minPhotosCount = 2
	private let maxPhotosCount = 6
	private lazy var imagePickerDelegate = {
		let picker = ImagePickerDelegate()
		picker.imageCallback = { [weak self] images in
			self?.images.append(contentsOf: images)
			self?.selectedImage = self?.images.last

			if let firstImageSource = self?.images.first?.source {
				WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .addStationPhoto,
																		 .source: firstImageSource.parameterValue,
																		 .action: .completed])
			}
		}
		return picker
	}()



	init(useCase: PhotoGalleryUseCaseApi,
		 images: [String],
		 linkNavigator: LinkNavigation) {
		self.useCase = useCase
		self.linkNavigator = linkNavigator
		self.images = images.map { GalleryView.GalleryImage(remoteUrl: $0, uiImage: nil, metadata: nil, source: nil) }
		selectedImage = self.images.last
	}

	func handlePlusButtonTap() {
		openPhotoPicker(type: .camera)
	}

	func handleDeleteButtonTap(showAlert: Bool = true) {
		guard let selectedImage else {
			return
		}

		WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .removeStationPhoto,
																 .itemId: selectedImage.isRmemoteImage ? .remote : .local])

		let action: VoidCallback = { [weak self] in
			Task { @MainActor in
				guard let self,
					  let selectedImage = self.selectedImage else {
					return
				}
				let result = await self.delegate?.handleDeleteButtonTap(for: selectedImage)
				if result == true {
					self.selectedImage = self.images.last
				}

				defer {
//					self?.showShimmerLoading = false
				}

//				self?.showShimmerLoading = true

//				do {
//					try await self?.deleteImageImage(selectedImage)
//					self?.selectedImage = self?.images.last
//				} catch PhotosError.networkError(let error) {
//					let info = error.uiInfo
//					if let message = info.description?.attributedMarkdown {
//						Toast.shared.show(text: message)
//					}
//				}
//				catch {
//					Toast.shared.show(text: error.localizedDescription.attributedMarkdown ?? "")
//				}
			}
		}

		if selectedImage.remoteUrl != nil, showAlert {
			showDeleteAlert(dismissAction: action)
			return
		}

		action()
	}

	func handleGalleryButtonTap() {
		openPhotoPicker(type: .photoLibrary)
	}

	func handleInstructionsButtonTap() {
		showInstructions = true
	}

	func viewLoaded() {
		if images.isEmpty {
			openCamera()
		}
	}

	func handleOpenSettingsTap() {
		linkNavigator.openUrl(UIApplication.openSettingsURLString)
	}
}

private extension GalleryImagesViewModel {
	func openPhotoPicker(type: PickerType) {
		WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .addStationPhoto,
																 .source: type.parameterValue,
																 .action: .started])

		guard images.count < maxPhotosCount else {
			if let text = LocalizableString.PhotoVerification.maxLimitPhotosInfo(maxPhotosCount).localized.attributedMarkdown {
				Toast.shared.show(text: text, type: .info, visibleDuration: 5.0)
			}
			return
		}

		switch type {
			case .camera:
				openCamera()
			case .photoLibrary:
				openPhotoGallery()
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

	func openPhotoGallery() {
		var configuration = PHPickerConfiguration()
		configuration.filter = .images
		configuration.selectionLimit = maxPhotosCount - images.count

		let picker = PHPickerViewController(configuration: configuration)
		picker.delegate = imagePickerDelegate
		UIApplication.shared.topViewController?.present(picker, animated: true)
	}

	func showDeleteAlert(dismissAction: @escaping VoidCallback) {
		let message = LocalizableString.PhotoVerification.deletePhotoAlertMessage.localized
		let exitAction: AlertHelper.AlertObject.Action = (LocalizableString.delete.localized, { _ in  dismissAction() })
		let alertObject = AlertHelper.AlertObject(title: LocalizableString.PhotoVerification.deletePhotoAlertTitle.localized,
												  message: message,
												  cancelActionTitle: LocalizableString.back.localized,
												  cancelAction: {},
												  okAction: exitAction)

		AlertHelper().showAlert(alertObject)
	}
}

private class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
	var imageCallback: (([GalleryView.GalleryImage]) -> Void)?

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		let metadata = info[.mediaMetadata] as? NSDictionary
		Task { @MainActor in
			if let image = info[.originalImage] as? UIImage {
				imageCallback?([GalleryView.GalleryImage(remoteUrl: nil, uiImage: image, metadata: metadata, source: .camera)])
			}
		}

		picker.dismiss(animated: true)
	}

	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		picker.dismiss(animated: true, completion: nil)

		nonisolated(unsafe) var images: [GalleryView.GalleryImage] = []
		let dispatchGroup = DispatchGroup()
		results.forEach { result in
			guard result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else {
				return
			}

			dispatchGroup.enter()
			result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
				defer {
					dispatchGroup.leave()
				}

				guard let url,
					  let data = try? Data(contentsOf: url) else {
					return
				}

				let options = [kCGImageSourceShouldCache as String:  kCFBooleanFalse]
				let imgSrc = CGImageSourceCreateWithData(data as CFData, options as CFDictionary)
				let metadata = CGImageSourceCopyPropertiesAtIndex(imgSrc!, 0, options as CFDictionary)
				if let image = UIImage(data: data) {
					images.append(GalleryView.GalleryImage(remoteUrl: nil, uiImage: image, metadata: metadata, source: .library))
				}
			}
		}

		dispatchGroup.notify(queue: .main) { [weak self] in
			self?.imageCallback?(images)
		}
	}

}

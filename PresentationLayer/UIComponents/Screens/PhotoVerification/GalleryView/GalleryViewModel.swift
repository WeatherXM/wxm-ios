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
class GalleryViewModel: ObservableObject {
	@Published var subtitle: String? = ""
	@Published var images: [GalleryView.GalleryImage] = [] {
		didSet {
			updateSubtitle()
		}
	}
	@Published var selectedImage: GalleryView.GalleryImage?
	@Published var isCameraDenied: Bool = false
	@Published var showInstructions: Bool = false
	@Published var showShimmerLoading: Bool = false
	@Published var showLoading: Bool = false
	let loadingTitle: String = LocalizableString.PhotoVerification.preparingUploadTitle.localized
	let loadingSubtitle: String = LocalizableString.PhotoVerification.preparingUploadDescription.localized
	@Published var showUploadStartedSuccess = false
	private(set) var uploadStartedObject: FailSuccessStateObject?
	@Published var showFail = false
	private(set) var failObject: FailSuccessStateObject?
	@Published var showShareSheet: Bool = false
	var shareImages: [UIImage]? {
		images.compactMap { $0.uiImage?.scaleDown(newWidth: 800.0) }
	}
	var localImages: [GalleryView.GalleryImage]? {
		images.filter { $0.uiImage != nil }
	}
	var isPlusButtonEnabled: Bool {
		useCase.getCameraPermission() != .denied
	}
	var isUploadButtonEnabled: Bool {
		images.count >= minPhotosCount && localImages?.isEmpty == false
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
	private let useCase: PhotoGalleryUseCaseApi
	private let isNewPhotoVerification: Bool
	private let linkNavigator: LinkNavigation
	private lazy var imagePickerDelegate = {
		let picker = ImagePickerDelegate(useCase: useCase, deviceId: deviceId)
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

	init(deviceId: String,
		 images: [String],
		 photoGalleryUseCase: PhotoGalleryUseCaseApi,
		 isNewPhotoVerification: Bool,
		 linkNavigation: LinkNavigation = LinkNavigationHelper()) {
		self.deviceId = deviceId
		self.useCase = photoGalleryUseCase
		self.images = images.map { GalleryView.GalleryImage(remoteUrl: $0, uiImage: nil, metadata: nil, source: nil) }
		self.isNewPhotoVerification = isNewPhotoVerification
		self.linkNavigator = linkNavigation
		selectedImage = self.images.last
		updateSubtitle()
		updateCameraPermissionState()
	}

	func handlePlusButtonTap() {
		openPhotoPicker(type: .camera)
	}

	func handleDeleteButtonTap(showAlert: Bool = true) {
		guard let selectedImage else {
			return
		}

		let action: VoidCallback = { [weak self] in
			Task { @MainActor in
				defer {
					self?.showShimmerLoading = false
				}
				
				self?.showShimmerLoading = true

				do {
					try await self?.deleteImageImage(selectedImage)
					self?.selectedImage = self?.images.last
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

	func handleUploadButtonTap(dismissAction: DismissAction?, showAlert: Bool = true) {
		WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .startUploadingPhotos])

		guard let localImages = localImages else {
			return
		}

		let action: VoidCallback = { [weak self] in
			Task { @MainActor in
				guard let self else { return }

				do {
					self.showLoading = true
					try self.useCase.clearLocalImages(deviceId: self.deviceId)
					let fileUrls = await localImages.asyncCompactMap { try? await self.useCase.saveImage($0.uiImage!,
																										 deviceId: self.deviceId,
																										 metadata: $0.metadata,
																										 userComment: $0.source?.sourceValue ?? "")}
					try await self.useCase.startFilesUpload(deviceId: self.deviceId, files: fileUrls.compactMap { try? $0.asURL() })
					self.showLoading = false
					self.showUploadStarted { dismissAction?() }
				} catch PhotosError.networkError(let error) {
					self.showLoading = false
					self.showFail(error: error)
				}
				catch {
					self.showLoading = false
					Toast.shared.show(text: error.localizedDescription.attributedMarkdown ?? "")
				}
			}
		}

		if showAlert {
			showUploadAlert(dismissAction: action)
			return
		}

		action()
	}

	func handleOpenSettingsTap() {
		linkNavigator.openUrl(UIApplication.openSettingsURLString)
	}

	func viewLoaded() {
		if images.isEmpty {
			openCamera()
		}
	}

	func handleBackButtonTap(dismissAction: DismissAction) {
		if isNewPhotoVerification {
			showExitAlert(message: LocalizableString.PhotoVerification.exitPhotoVerificationText.localized) {
				WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .exitPhotoVerification])
				dismissAction()
			}

			return
		}

		let remoteImageCount = images.filter { $0.remoteUrl != nil }.count
		if remoteImageCount < minPhotosCount {
			showExitAlert(message: LocalizableString.PhotoVerification.exitPhotoVerificationMinimumPhotosText.localized) { [weak self] in
				self?.deleteAllImages()
				WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .exitPhotoVerification])
				dismissAction()
			}

			return
		}

		WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .exitPhotoVerification])
		dismissAction()
	}

	func handleOnAppear() {
		WXMAnalytics.shared.trackScreen(.stationPhotosGallery)
	}
}

extension GalleryViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
	}
}

private class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
	var imageCallback: (([GalleryView.GalleryImage]) -> Void)?
	private let useCase: PhotoGalleryUseCaseApi
	private let deviceId: String

	init(useCase: PhotoGalleryUseCaseApi, deviceId: String) {
		self.useCase = useCase
		self.deviceId = deviceId
	}

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

private extension GalleryViewModel {
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

	func openPhotoGallery() {
		var configuration = PHPickerConfiguration()
		configuration.filter = .images
		configuration.selectionLimit = maxPhotosCount - images.count

		let picker = PHPickerViewController(configuration: configuration)
		picker.delegate = imagePickerDelegate
		UIApplication.shared.topViewController?.present(picker, animated: true)
	}

	func showExitAlert(message: String, dismissAction: @escaping VoidCallback) {
		let exitAction: AlertHelper.AlertObject.Action = (LocalizableString.exitAnyway.localized, { _ in  dismissAction() })
		let verifyAction: AlertHelper.AlertObject.Action = (LocalizableString.PhotoVerification.stayAndVerify.localized, { _ in  })
		let alertObject = AlertHelper.AlertObject(title: LocalizableString.PhotoVerification.exitPhotoVerification.localized,
												  message: message,
												  cancelActionTitle: exitAction.title,
												  cancelAction: { exitAction.action(nil) },
												  okAction: verifyAction)

		AlertHelper().showAlert(alertObject)
	}

	func showUploadStarted(dismissAction: @escaping VoidCallback) {
		let obj = FailSuccessStateObject(type: .changeFrequency,
										 title: LocalizableString.PhotoVerification.uploadStartedSuccessfully.localized,
										 subtitle: LocalizableString.PhotoVerification.uploadStartedSuccessfullyDescription.localized.attributedMarkdown,
										 cancelTitle: LocalizableString.continue.localized,
										 retryTitle: LocalizableString.share.localized,
										 actionButtonsLayout: .vertical,
										 actionButtonsAtTheBottom: true,
										 contactSupportAction: nil,
										 cancelAction: {
			dismissAction()
		},
										 retryAction: { [weak self] in
			self?.showShareSheet = true
		})

		uploadStartedObject = obj
		showUploadStartedSuccess = true
	}

	func showUploadAlert(dismissAction: @escaping VoidCallback) {
		let message = LocalizableString.PhotoVerification.uploadPhotosAlertMessage.localized
		let exitAction: AlertHelper.AlertObject.Action = (LocalizableString.PhotoVerification.upload.localized, { _ in  dismissAction() })
		let alertObject = AlertHelper.AlertObject(title: LocalizableString.PhotoVerification.uploadPhotosAlertTitle.localized,
												  message: message,
												  cancelActionTitle: LocalizableString.back.localized,
												  cancelAction: {},
												  okAction: exitAction)

		AlertHelper().showAlert(alertObject)
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

	func showFail(error: NetworkErrorResponse) {
		let info = error.uiInfo
		let obj = info.defaultFailObject(type: .gallery) { [weak self] in
			self?.showFail = false
		}

		failObject = obj
		showFail = true
	}

	func deleteImageImage(_ image: GalleryView.GalleryImage) async throws {
		if let remoteUrl = image.remoteUrl {
			try await useCase.deleteImage(remoteUrl, deviceId: deviceId)
		}
		images.removeAll(where: { $0 == image })
	}

	func deleteAllImages() {
		nonisolated(unsafe) let imagesToDelete = images

		Task { @MainActor in
			await imagesToDelete.asyncForEach { galleryImage in
				nonisolated(unsafe) let image = galleryImage
				try? await deleteImageImage(image)
			}
		}
	}
}

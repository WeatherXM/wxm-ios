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
import Combine

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
		galleryImagesViewModel.images.compactMap { $0.uiImage?.scaleDown(newWidth: 800.0) }
	}
	var localImages: [GalleryView.GalleryImage]? {
		galleryImagesViewModel.images.filter { $0.uiImage != nil }
	}
	var isPlusButtonEnabled: Bool {
		useCase.getCameraPermission() != .denied
	}
	var isUploadButtonEnabled: Bool {
		galleryImagesViewModel.images.count >= minPhotosCount && localImages?.isEmpty == false
	}
	var backButtonIcon: FontIcon {
		if isNewPhotoVerification {
			return .xmark
		}

		return .arrowLeft
	}
	let galleryImagesViewModel: GalleryImagesViewModel
	private let minPhotosCount = 2
	private let maxPhotosCount = 6
	let deviceId: String
	private let useCase: PhotoGalleryUseCaseApi
	private let isNewPhotoVerification: Bool
	private let linkNavigator: LinkNavigation
	private var cancellables: Set<AnyCancellable> = []

	init(deviceId: String,
		 images: [String],
		 photoGalleryUseCase: PhotoGalleryUseCaseApi,
		 isNewPhotoVerification: Bool,
		 linkNavigation: LinkNavigation = LinkNavigationHelper()) {
		self.deviceId = deviceId
		self.useCase = photoGalleryUseCase
		self.isNewPhotoVerification = isNewPhotoVerification
		self.linkNavigator = linkNavigation
		self.galleryImagesViewModel = ViewModelsFactory.getGalleryImagesViewModel(images: images)
		self.galleryImagesViewModel.delegate = self
		self.galleryImagesViewModel.$images.sink { [weak self] images in
			self?.updateSubtitle()
		}.store(in: &cancellables)
		updateSubtitle()
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

	func handleBackButtonTap(dismissAction: DismissAction) {
		if isNewPhotoVerification {
			showExitAlert(message: LocalizableString.PhotoVerification.exitPhotoVerificationText.localized) {
				WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .exitPhotoVerification])
				dismissAction()
			}

			return
		}

		let remoteImageCount = galleryImagesViewModel.images.filter { $0.remoteUrl != nil }.count
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

extension GalleryViewModel: GalleryImagesViewModelDelegate {
	func handleDeleteButtonTap(for image: GalleryView.GalleryImage) async -> Bool {
		defer {
			showShimmerLoading = false
		}

		showShimmerLoading = true

		do {
			try await deleteImageImage(image)
			return true
		} catch PhotosError.networkError(let error) {
			let info = error.uiInfo
			if let message = info.description?.attributedMarkdown {
				Toast.shared.show(text: message)
			}
		} catch {
			Toast.shared.show(text: error.localizedDescription.attributedMarkdown ?? "")
		}

		return false
	}
}

extension GalleryViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
	}
}

private extension GalleryViewModel {

	func updateSubtitle() {
		let remainingCount = minPhotosCount - galleryImagesViewModel.images.count
		if remainingCount > 0 {
			subtitle = LocalizableString.PhotoVerification.morePhotosToUpload(remainingCount).localized
		} else {
			subtitle = nil
		}
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
		galleryImagesViewModel.images.removeAll(where: { $0 == image })
	}

	func deleteAllImages() {
		nonisolated(unsafe) let imagesToDelete = galleryImagesViewModel.images

		Task { @MainActor in
			await imagesToDelete.asyncForEach { galleryImage in
				nonisolated(unsafe) let image = galleryImage
				try? await deleteImageImage(image)
			}
		}
	}
}

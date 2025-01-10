//
//  PhotoVerificationStateViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 18/12/24.
//

import Foundation
import DomainLayer
import Combine

@MainActor
class PhotoVerificationStateViewModel: ObservableObject {
	@Published private(set) var state: PhotoVerificationStateView.State = .content(photos: [], isFailed: false)
	private var allPhotos: [NetworkDevicePhotosResponse] = []
	@Published private(set) var morePhotosCount: Int = 0
	private var cancellables: Set<AnyCancellable> = []
	private let deviceInfoUseCase: DeviceInfoUseCase?
	private let photoGalleryUseCase: PhotoGalleryUseCase?
	private let deviceId: String

	init(deviceId: String, deviceInfoUseCase: DeviceInfoUseCase?, photoGalleryUseCase: PhotoGalleryUseCase?) {
		self.deviceId = deviceId
		self.deviceInfoUseCase = deviceInfoUseCase
		self.photoGalleryUseCase = photoGalleryUseCase

		observePhotoUploadState()
	}

	func handleCancelUploadTap() {
		let yesAction: AlertHelper.AlertObject.Action = (LocalizableString.PhotoVerification.yesCancel.localized, { [weak self] _ in
			guard let self else {
				return
			}
			self.photoGalleryUseCase?.cancelUpload(deviceId: deviceId)
		})
		let alertObject = AlertHelper.AlertObject(title: LocalizableString.PhotoVerification.cancelUpload.localized,
												  message: LocalizableString.PhotoVerification.cancelUploadAlertMessage.localized,
												  cancelActionTitle: LocalizableString.back.localized,
												  cancelAction: {},
												  okAction: yesAction)

		AlertHelper().showAlert(alertObject)
	}

	func handleImageTap() {
		let route = PhotoIntroViewModel.getInitialRoute(deviceId: deviceId,
														images: allPhotos.compactMap { $0.url },
														isNewPhotoVerification: false)
		Router.shared.navigateTo(route)
	}

	func retryUpload() {
		Task {
			try? await photoGalleryUseCase?.retryUpload(deviceId: deviceId)
		}
	}

	func refresh() async -> NetworkErrorResponse? {
		await fetchPhotos()
	}
}

private extension PhotoVerificationStateViewModel {
	@MainActor
	func fetchPhotos() async -> NetworkErrorResponse? {
		do {
			guard let result = try await deviceInfoUseCase?.getDevicePhotos(deviceId: deviceId) else {
				return nil
			}

			switch result {
				case .success(let response):
					allPhotos = response
					updateState()
				case .failure(let error):
					updateState()
					return error
			}
		} catch {
			updateState()
			print(error)
		}

		return nil
	}

	func observePhotoUploadState() {
		photoGalleryUseCase?.uploadErrorPublisher.sink { deviceId, error in
			guard deviceId == self.deviceId else { return }
			self.updateState()
		}.store(in: &cancellables)

		photoGalleryUseCase?.uploadProgressPublisher.sink { deviceId, progress in
			guard deviceId == self.deviceId else { return }
			self.updateState()
		}.store(in: &cancellables)

		photoGalleryUseCase?.uploadCompletedPublisher.sink { deviceId, _ in
			guard deviceId == self.deviceId else { return }
			self.updateState()
		}.store(in: &cancellables)
	}

	func updateState() {
		let uploadState = photoGalleryUseCase?.getUploadState(deviceId: deviceId)
		var isFailed: Bool
		switch uploadState {
			case .uploading(let progress):
				state = .uploading(progress: progress)
				return
			case .failed:
				isFailed = true
			case nil:
				isFailed = false
		}

		let urls: [URL] = self.allPhotos.compactMap { photo in
			guard let url = photo.url else {
				return nil
			}
			return URL(string: url)
		}

		let urlsToShow = urls.prefix(2)
		let remainingCount = urls.dropFirst(2).count
		self.morePhotosCount = remainingCount
		self.state = .content(photos: Array(urlsToShow), isFailed: isFailed)
	}
}

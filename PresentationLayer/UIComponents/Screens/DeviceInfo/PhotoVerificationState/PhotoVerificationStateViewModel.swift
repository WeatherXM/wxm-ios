//
//  PhotoVerificationStateViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 18/12/24.
//

import Foundation
import DomainLayer
import Combine
import Toolkit

@MainActor
class PhotoVerificationStateViewModel: ObservableObject {
	@Published private(set) var state: PhotoVerificationStateView.State = .content(photos: [], isFailed: false)
	private var allPhotos: [NetworkDevicePhotosResponse] = []
	@Published private(set) var morePhotosCount: Int = 0
	private var cancellables: Set<AnyCancellable> = []
	private let deviceInfoUseCase: DeviceInfoUseCase?
	private let photoGalleryUseCase: PhotoGalleryUseCaseApi?
	private let deviceId: String

	init(deviceId: String, deviceInfoUseCase: DeviceInfoUseCase?, photoGalleryUseCase: PhotoGalleryUseCaseApi?) {
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
			WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .cancelUploadingPhotos])

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
		PhotoIntroViewModel.startPhotoVerification(deviceId: deviceId,
												   images: allPhotos.compactMap { $0.url },
												   isNewPhotoVerification: false)
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
					updateState(photosError: error)
					return error
			}
		} catch {
			updateState()
			print(error)
		}

		return nil
	}

	func observePhotoUploadState() {
		photoGalleryUseCase?.uploadErrorPublisher.sink { [weak self] deviceId, error in
			guard deviceId == self?.deviceId else { return }
			self?.updateState()
			Task { @MainActor [weak self] in
				await self?.fetchPhotos()
			}
		}.store(in: &cancellables)

		photoGalleryUseCase?.uploadProgressPublisher.sink { [weak self] deviceId, progress in
			guard deviceId == self?.deviceId else { return }
			self?.updateState()
		}.store(in: &cancellables)

		photoGalleryUseCase?.uploadCompletedPublisher.sink { [weak self] deviceId, _ in
			guard deviceId == self?.deviceId else { return }
			self?.updateState()
			Task { @MainActor [weak self] in
				await self?.fetchPhotos()
			}
		}.store(in: &cancellables)

		NotificationCenter.default.addObserver(forName: .devicePhotoDeleted,
											   object: nil,
											   queue: .main) { [weak self] notification in
			guard notification.object as? String == self?.deviceId else {
				return
			}

			Task { @MainActor [weak self] in
				await self?.refresh()
			}
		}
	}

	func updateState(photosError: NetworkErrorResponse? = nil) {
		guard photosError == nil else {
			state = .fetchPhotosFailed
			return
		}

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

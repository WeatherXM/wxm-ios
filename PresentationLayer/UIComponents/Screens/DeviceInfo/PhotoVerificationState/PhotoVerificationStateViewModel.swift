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
	@Published private(set) var state: PhotoVerificationStateView.State = .isLoading
	private var allPhotos: [NetworkDevicePhotosResponse] = []
	@Published private(set) var morePhotosCount: Int = 0
	private var cancellable: Set<AnyCancellable> = []
	private let deviceInfoUseCase: DeviceInfoUseCase?
	private let deviceId: String

	init(deviceId: String, deviceInfoUseCase: DeviceInfoUseCase?) {
		self.deviceId = deviceId
		self.deviceInfoUseCase = deviceInfoUseCase

		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

			self.fetchPhotos()
		}
	}

	func handleCancelUploadTap() {
		let yesAction: AlertHelper.AlertObject.Action = (LocalizableString.PhotoVerification.yesCancel.localized, { _ in   })
		let alertObject = AlertHelper.AlertObject(title: LocalizableString.PhotoVerification.cancelUpload.localized,
												  message: LocalizableString.PhotoVerification.cancelUploadAlertMessage.localized,
												  cancelActionTitle: LocalizableString.back.localized,
												  cancelAction: {},
												  okAction: yesAction)

		AlertHelper().showAlert(alertObject)

	}

	func handleImageTap() {
		let route = PhotoIntroViewModel.getInitialRoute(images: allPhotos.compactMap { $0.url }, isNewPhotoVerification: false)
		Router.shared.navigateTo(route)
	}
}

private extension PhotoVerificationStateViewModel {
	func fetchPhotos() {
		state = .isLoading
		do {
			try deviceInfoUseCase?.getDevicePhotos(deviceId: deviceId).sink { [weak self] response in
				guard let self else { return }

				let urls: [URL]? = response.value?.compactMap { photo in
					guard let url = photo.url else {
						return nil
					}
					return URL(string: url)
				}

				self.allPhotos = response.value ?? []

				if let urls {
					let urlsToShow = urls.prefix(2)
					let remainingCount = urls.dropFirst(2).count
					self.morePhotosCount = remainingCount
					self.state = .content(photos: Array(urlsToShow), isFailed: false)
				} else {
					self.state = .content(photos: [], isFailed: false)
				}
			}.store(in: &cancellable)
		} catch {
			state = .content(photos: [], isFailed: false)
			print(error)
		}
	}
}

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
	private var cancellable: Set<AnyCancellable> = []
	private let deviceInfoUseCase: DeviceInfoUseCase?
	private let deviceId: String

	init(deviceId: String, deviceInfoUseCase: DeviceInfoUseCase?) {
		self.deviceId = deviceId
		self.deviceInfoUseCase = deviceInfoUseCase
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

	func refresh() async -> NetworkErrorResponse? {
		// Comment the following line and ucomment one of the rest to test each ui case along with the
		// return nil at the bottom
		await fetchPhotos()

		// ---Uploading state---
		//state = .uploading(progress: 63)

		// ---Empty---
		//state = .content(photos: [], isFailed: false)

		//---Empty with error---
		//state = .content(photos: [], isFailed: true)

		// ---Photos with error---
//		state = .content(photos: [URL(string: "https://i0.wp.com/weatherxm.com/wp-content/uploads/2023/09/5-5.png")!,
//								  URL(string: "https://docs.weatherxm.com/img/wxm-devices/deployments/good-example-1.jpg")!], isFailed: true)

		//return nil
	}
}

private extension PhotoVerificationStateViewModel {
	@MainActor
	func fetchPhotos() async -> NetworkErrorResponse? {
		do {
			guard let result = try await deviceInfoUseCase?.getDevicePhotos(deviceId: deviceId).toAsync().result else {
				return nil
			}

			switch result {
				case .success(let response):
					let urls: [URL]? = response.compactMap { photo in
						guard let url = photo.url else {
							return nil
						}
						return URL(string: url)
					}

					self.allPhotos = response

					if let urls {
						let urlsToShow = urls.prefix(2)
						let remainingCount = urls.dropFirst(2).count
						self.morePhotosCount = remainingCount
						self.state = .content(photos: Array(urlsToShow), isFailed: false)
					} else {
						self.state = .content(photos: [], isFailed: false)
					}
				case .failure(let error):
					return error
			}
		} catch {
			state = .content(photos: [], isFailed: false)
			print(error)
		}

		return nil
	}
}

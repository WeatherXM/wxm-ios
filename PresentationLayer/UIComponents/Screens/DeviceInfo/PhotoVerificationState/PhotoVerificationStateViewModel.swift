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
	@Published private(set) var state: PhotoVerificationStateView.State = .empty
	@Published private(set) var morePhotosCount: Int = 0
	private var cancellable: Set<AnyCancellable> = []
	private let deviceInfoUseCase: DeviceInfoUseCase?
	private let deviceId: String

	init(deviceId: String, deviceInfoUseCase: DeviceInfoUseCase?) {
		self.deviceId = deviceId
		self.deviceInfoUseCase = deviceInfoUseCase

		fetchPhotos()
	}
}

private extension PhotoVerificationStateViewModel {
	func fetchPhotos() {
		do {
			try deviceInfoUseCase?.getDevicePhotos(deviceId: deviceId).sink { [weak self] response in
				guard let self else { return }

				let urls: [URL]? = response.value?.compactMap { photo in
					guard let url = photo.url else {
						return nil
					}
					return URL(string: url)
				}

				if let urls {
					let urlsToShow = urls.prefix(2)
					let remainingCount = urls.dropFirst(2).count
					self.morePhotosCount = remainingCount
					self.state = .content(photos: Array(urlsToShow))
				} else {
					self.state = .empty
				}
			}.store(in: &cancellable)
		} catch {
			print(error)
		}
	}
}

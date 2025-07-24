//
//  ClaimDevicePhotosManager.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/7/25.
//

import Foundation

@MainActor
class ClaimDevicePhotosManager {
	static let shared = ClaimDevicePhotosManager()
	private(set) var photos: [String: [GalleryView.GalleryImage]] = [:]

	private init() {}

	func setPhotos(_ photos: [GalleryView.GalleryImage], for deviceId: String) {
		self.photos[deviceId] = photos
	}

	func getPhotos(for deviceId: String) -> [GalleryView.GalleryImage]? {
		return photos[deviceId]
	}
}

extension ClaimDevicePhotosManager {
	static let tempHeliumSerialNumber = "temp-helium-serial-number"
}

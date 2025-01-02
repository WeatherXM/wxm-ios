//
//  PhotoGalleryUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 10/12/24.
//

import Foundation
import UIKit
import AVFoundation

public struct PhotoGalleryUseCase: Sendable {

	public var areTermsAccepted: Bool { photosRepository.areTermsAccepted }

	private let photosRepository: PhotosRepository

	public init(photosRepository: PhotosRepository) {
		self.photosRepository = photosRepository
	}

	public func setTermsAccepted(_ termsAccepted: Bool) {
		photosRepository.setTermsAccepted(termsAccepted)
	}

	public func saveImage(_ image: UIImage, metadata: NSDictionary?) async throws -> String? {
		try await photosRepository.saveImage(image, metadata: metadata)
	}

	public func deleteImage(_ imageUrl: String, deviceId: String) async throws {
		try await photosRepository.deleteImage(imageUrl, deviceId: deviceId)
	}

	public func getCameraPermission() -> AVAuthorizationStatus {
		photosRepository.getCameraPermission()
	}

	public func requestCameraPermission() async -> AVAuthorizationStatus {
		await photosRepository.reqeustCameraPermission()
	}

	public func purgeImages() throws {
		try photosRepository.purgeImages()
	}
}

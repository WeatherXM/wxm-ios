//
//  PhotoGalleryUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 10/12/24.
//

import Foundation
import UIKit
import AVFoundation
@preconcurrency import Combine

public struct PhotoGalleryUseCase: Sendable {

	public var areTermsAccepted: Bool { photosRepository.areTermsAccepted }
	public var uploadProgressPublisher: AnyPublisher<Double?, PhotosError>

	private let photosRepository: PhotosRepository

	public init(photosRepository: PhotosRepository) {
		self.photosRepository = photosRepository
		uploadProgressPublisher = photosRepository.uploadProgressPublisher.map { res in
			return res
		}.mapError { error in
			return PhotosError.uploadFailed(error)
		}.eraseToAnyPublisher()
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

	public func startFilesUpload(deviceId: String, files: [URL]) async throws {
		try await photosRepository.startFilesUpload(deviceId: deviceId, files: files)
	}
}

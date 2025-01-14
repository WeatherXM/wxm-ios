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
	public var uploadProgressPublisher: AnyPublisher<(String, Double?), Never>
	public var uploadErrorPublisher: AnyPublisher<(String, Error), Never>
	public var uploadCompletedPublisher: AnyPublisher<(String, Int), Never>
	public var uploadStartedPublisher: AnyPublisher<(String), Never>

	private let photosRepository: PhotosRepository

	public init(photosRepository: PhotosRepository) {
		self.photosRepository = photosRepository
		uploadProgressPublisher = photosRepository.uploadProgressPublisher
		uploadErrorPublisher = photosRepository.uploadErrorPublisher
		uploadCompletedPublisher = photosRepository.uploadCompletedPublisher
		uploadStartedPublisher = photosRepository.uploadStartedPublisher
	}

	public func getUploadInProgressDeviceId() -> String? {
		photosRepository.getUploadInProgressDeviceId()
	}

	public func setTermsAccepted(_ termsAccepted: Bool) {
		photosRepository.setTermsAccepted(termsAccepted)
	}

	public func saveImage(_ image: UIImage, deviceId: String, metadata: NSDictionary?) async throws -> String? {
		try await photosRepository.saveImage(image, deviceId: deviceId, metadata: metadata)
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

	public func clearLocalImages(deviceId: String) throws {
		try photosRepository.clearLocalImages(deviceId: deviceId)
	}

	public func startFilesUpload(deviceId: String, files: [URL]) async throws {
		try await photosRepository.startFilesUpload(deviceId: deviceId, files: files)
	}

	public func retryUpload(deviceId: String) async throws {
		try await photosRepository.retryFilesUpload(deviceId: deviceId)
	}

	public func cancelUpload(deviceId: String) {
		photosRepository.cancelUpload(deviceId: deviceId)
	}

	public func getUploadState(deviceId: String) -> PhotoUploadState? {
		photosRepository.getUploadState(deviceId: deviceId)
	}
}

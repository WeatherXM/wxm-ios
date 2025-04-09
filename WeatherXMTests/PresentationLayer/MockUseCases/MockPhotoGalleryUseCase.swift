//
//  MockPhotoGalleryUseCase.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

import Foundation
import DomainLayer
import Combine
import UIKit
import AVFoundation

final class MockPhotoGalleryUseCase: PhotoGalleryUseCaseApi {
	nonisolated(unsafe) private var termsAcceptedValue: Bool = false
	nonisolated(unsafe) private let uploadProgressValueSubject: PassthroughSubject<(String, Double?), Never> = .init()
	nonisolated(unsafe) private let uploadErrorPassthroughSubject: PassthroughSubject<(String, Error), Never> = .init()
	nonisolated(unsafe) private let uploadCompletedPassthroughSubject: PassthroughSubject<(String, Int), Never> = .init()
	nonisolated(unsafe) private let uploadStartedPassthroughSubject: PassthroughSubject<String, Never> = .init()
	nonisolated(unsafe) private(set) var imageSaved: Bool = false
	nonisolated(unsafe) private(set) var imageDeleted: Bool = false
	nonisolated(unsafe) private(set) var imagesPurged: Bool = false
	nonisolated(unsafe) private(set) var localImagesCleared: Bool = false
	nonisolated(unsafe) private(set) var fileUploadStarted: Bool = false
	nonisolated(unsafe) private(set) var uploadRetried: Bool = false
	nonisolated(unsafe) private(set) var uploadCanceled: Bool = false

	var areTermsAccepted: Bool {
		termsAcceptedValue
	}
	nonisolated(unsafe) var uploadProgressPublisher: AnyPublisher<(String, Double?), Never>
	nonisolated(unsafe) var uploadErrorPublisher: AnyPublisher<(String, any Error), Never>
	nonisolated(unsafe) var uploadCompletedPublisher: AnyPublisher<(String, Int), Never>
	nonisolated(unsafe) var uploadStartedPublisher: AnyPublisher<(String), Never>

	init() {
		uploadProgressPublisher = uploadProgressValueSubject.eraseToAnyPublisher()
		uploadErrorPublisher = uploadErrorPassthroughSubject.eraseToAnyPublisher()
		uploadCompletedPublisher = uploadCompletedPassthroughSubject.eraseToAnyPublisher()
		uploadStartedPublisher = uploadStartedPassthroughSubject.eraseToAnyPublisher()
	}

	func getUploadInProgressDeviceId() -> String? {
		"124"
	}

	func setTermsAccepted(_ termsAccepted: Bool) {
		termsAcceptedValue = termsAccepted
	}

	func saveImage(_ image: UIImage, deviceId: String, metadata: NSDictionary?) async throws -> String? {
		imageSaved = true
		return ""
	}

	func deleteImage(_ imageUrl: String, deviceId: String) async throws {
		imageDeleted = true
	}

	func getCameraPermission() -> AVAuthorizationStatus {
		.authorized
	}

	func requestCameraPermission() async -> AVAuthorizationStatus {
		.authorized
	}

	func purgeImages() throws {
		imagesPurged = true
	}

	func clearLocalImages(deviceId: String) throws {
		localImagesCleared = true
	}

	func startFilesUpload(deviceId: String, files: [URL]) async throws {
		fileUploadStarted = true
	}

	func retryUpload(deviceId: String) async throws {
		uploadRetried = true
	}

	func cancelUpload(deviceId: String) {
		uploadCanceled = true
	}

	func getUploadState(deviceId: String) -> PhotoUploadState? {
		nil
	}
}

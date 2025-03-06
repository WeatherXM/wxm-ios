//
//  MockPhotosRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 6/3/25.
//

import Foundation
@testable import DomainLayer
@preconcurrency import Combine
import CoreLocation
import UIKit
import AVFoundation

final class MockPhotosRepositoryImpl {
	private let uploadProgressValueSubject: PassthroughSubject<(String, Double?), Never> = .init()
	private let uploadErrorPassthroughSubject: PassthroughSubject<(String, Error), Never> = .init()
	private let uploadCompletedPassthroughSubject: PassthroughSubject<(String, Int), Never> = .init()
	private let uploadStartedPassthroughSubject: PassthroughSubject<String, Never> = .init()

	nonisolated(unsafe) private var termsAccepted: Bool = false
	nonisolated(unsafe) private(set) var isImageDeleted: Bool = false
	nonisolated(unsafe) private(set) var areImagesPurged: Bool = false
	nonisolated(unsafe) private(set) var areLocalImagesCleared: Bool = false
	nonisolated(unsafe) private(set) var uploadStarted: Bool = false
	nonisolated(unsafe) private(set) var retryUploadStarted: Bool = false
	nonisolated(unsafe) private(set) var uploadCancelled: Bool = false

	func sendUploadProgress(_ deviceId: String, _ progress: Double?) {
		uploadProgressValueSubject.send((deviceId, progress))
	}

	func sendUploadError(_ deviceId: String, _ error: Error) {
		uploadErrorPassthroughSubject.send((deviceId, error))
	}

	func sendUploadCompleted(_ deviceId: String, _ count: Int) {
		uploadCompletedPassthroughSubject.send((deviceId, count))
	}

	func sendUploadStarted(_ deviceId: String) {
		uploadStartedPassthroughSubject.send(deviceId)
	}
}

extension MockPhotosRepositoryImpl: PhotosRepository {
	var areTermsAccepted: Bool {
		termsAccepted
	}

	var uploadProgressPublisher: AnyPublisher<(String, Double?), Never> {
		uploadProgressValueSubject.eraseToAnyPublisher()
	}

	var uploadErrorPublisher: AnyPublisher<(String, any Error), Never> {
		uploadErrorPassthroughSubject.eraseToAnyPublisher()
	}

	var uploadCompletedPublisher: AnyPublisher<(String, Int), Never> {
		uploadCompletedPassthroughSubject.eraseToAnyPublisher()
	}

	var uploadStartedPublisher: AnyPublisher<String, Never> {
		uploadStartedPassthroughSubject.eraseToAnyPublisher()
	}

	func getUploadInProgressDeviceId() -> String? {
		""
	}
	
	func setTermsAccepted(_ termsAccepted: Bool) {
		self.termsAccepted = termsAccepted
	}
	
	func saveImage(_ image: UIImage, deviceId: String, metadata: NSDictionary?) async throws -> String? {
		""
	}
	
	func deleteImage(_ imageUrl: String, deviceId: String) async throws {
		isImageDeleted = true
	}
	
	func getCameraPermission() -> AVAuthorizationStatus {
		.notDetermined
	}
	
	func requestCameraPermission() async -> AVAuthorizationStatus {
		.authorized
	}
	
	func purgeImages() throws {
		areImagesPurged = true
	}
	
	func clearLocalImages(deviceId: String) throws {
		areLocalImagesCleared = true
	}
	
	func startFilesUpload(deviceId: String, files: [URL]) async throws {
		uploadStarted = true
	}
	
	func retryFilesUpload(deviceId: String) async throws {
		retryUploadStarted = true
	}
	
	func cancelUpload(deviceId: String) {
		uploadCancelled = true
	}
	
	func getUploadState(deviceId: String) -> PhotoUploadState? {
		.failed
	}
}

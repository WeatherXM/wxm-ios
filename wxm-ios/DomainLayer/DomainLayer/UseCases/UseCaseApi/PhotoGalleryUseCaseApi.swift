//
//  PhotoGalleryUseCaseApi.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

import Combine
import UIKit
import AVFoundation

public protocol PhotoGalleryUseCaseApi: Sendable {
	var areTermsAccepted: Bool { get }
	var uploadProgressPublisher: AnyPublisher<(String, Double?), Never> { get set }
	var uploadErrorPublisher: AnyPublisher<(String, Error), Never> { get set }
	var uploadCompletedPublisher: AnyPublisher<(String, Int), Never> { get set }
	var uploadStartedPublisher: AnyPublisher<(String), Never> { get set }

	func getUploadInProgressDeviceId() -> String?
	func setTermsAccepted(_ termsAccepted: Bool)
	func saveImage(_ image: UIImage, deviceId: String, metadata: NSDictionary?) async throws -> String?
	func deleteImage(_ imageUrl: String, deviceId: String) async throws
	func getCameraPermission() -> AVAuthorizationStatus
	func requestCameraPermission() async -> AVAuthorizationStatus
	func purgeImages() throws
	func clearLocalImages(deviceId: String) throws
	func startFilesUpload(deviceId: String, files: [URL]) async throws
	func retryUpload(deviceId: String) async throws
	func cancelUpload(deviceId: String)
	func getUploadState(deviceId: String) -> PhotoUploadState?
}

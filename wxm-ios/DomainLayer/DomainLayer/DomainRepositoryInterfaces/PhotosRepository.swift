//
//  PhotosRepository.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 10/12/24.
//

import Foundation
import UIKit
import AVFoundation
import Combine

public extension Notification.Name {
	static let devicePhotoDeleted = Notification.Name("photos.deleted")
}

public protocol PhotosRepository: Sendable {
	var areTermsAccepted: Bool { get }
	var uploadProgressPublisher: AnyPublisher<(String, Double?), Never> { get }
	var uploadErrorPublisher: AnyPublisher<(String, Error), Never> { get }
	var uploadCompletedPublisher: AnyPublisher<(String, Int), Never> { get }
	var uploadStartedPublisher: AnyPublisher<String, Never> { get }
	func getUploadInProgressDeviceId() -> String?
	func setTermsAccepted(_ termsAccepted: Bool)
	func saveImage(_ image: UIImage, deviceId: String, metadata: NSDictionary?) async throws -> String?
	func deleteImage(_ imageUrl: String, deviceId: String) async throws
	func getCameraPermission() -> AVAuthorizationStatus
	func requestCameraPermission() async -> AVAuthorizationStatus
	func purgeImages() throws
	func clearLocalImages(deviceId: String) throws
	func startFilesUpload(deviceId: String, files: [URL]) async throws
	func retryFilesUpload(deviceId: String) async throws
	func cancelUpload(deviceId: String)
	func getUploadState(deviceId: String) -> PhotoUploadState?
}

public enum PhotosError: CustomStringConvertible, Error {

	public var description: String {
		switch self {
			case .imageNotFound: return "imageNotFound"
			case .failedToSaveImage: return "failedToSaveImage"
			case .failedToDeleteImage: return "failedToDeleteImage"
			case .networkError: return "networkError"
			case .uploadFailed: return "uploadFailed"
		}
	}

	case imageNotFound
	case failedToSaveImage
	case failedToDeleteImage
	case networkError(NetworkErrorResponse)
	case uploadFailed(Error)
}

public enum PhotoUploadState: Equatable {
	case uploading(Double)
	case failed
}

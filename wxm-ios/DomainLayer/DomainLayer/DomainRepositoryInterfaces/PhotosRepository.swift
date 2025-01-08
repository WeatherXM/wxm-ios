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

public protocol PhotosRepository: Sendable {
	var areTermsAccepted: Bool { get }
	var uploadProgressPublisher: AnyPublisher<(String, Double?), Never> { get }
	var uploadErrorPublisher: AnyPublisher<(String, Error), Never> { get }
	func getUploadInProgressDeviceId() async -> String?
	func setTermsAccepted(_ termsAccepted: Bool)
	func saveImage(_ image: UIImage, metadata: NSDictionary?) async throws -> String?
	func deleteImage(_ imageUrl: String, deviceId: String) async throws
	func getCameraPermission() -> AVAuthorizationStatus
	func reqeustCameraPermission() async -> AVAuthorizationStatus
	func purgeImages() throws
	func startFilesUpload(deviceId: String, files: [URL]) async throws
	func retryFilesUpload(deviceId: String) async throws
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

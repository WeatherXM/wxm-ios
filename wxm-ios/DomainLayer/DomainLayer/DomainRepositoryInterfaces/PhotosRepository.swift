//
//  PhotosRepository.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 10/12/24.
//

import Foundation
import UIKit
import AVFoundation

public protocol PhotosRepository: Sendable {
	var areTermsAccepted: Bool { get }
	func setTermsAccepted(_ termsAccepted: Bool)	
	func saveImage(_ image: UIImage, metadata: NSDictionary?) async throws -> String?
	func deleteImage(_ imageUrl: String, deviceId: String) async throws
	func getCameraPermission() -> AVAuthorizationStatus
	func reqeustCameraPermission() async -> AVAuthorizationStatus
	func purgeImages() throws
	func startFilesUpload(deviceId: String, files: [URL]) async throws
}

public enum PhotosError: CustomStringConvertible, Error {

	public var description: String {
		switch self {
			case .imageNotFound: return "imageNotFound"
			case .failedToSaveImage: return "failedToSaveImage"
			case .failedToDeleteImage: return "failedToDeleteImage"
			case .networkError: return "networkError"
		}
	}

	case imageNotFound
	case failedToSaveImage
	case failedToDeleteImage
	case networkError(NetworkErrorResponse)
}

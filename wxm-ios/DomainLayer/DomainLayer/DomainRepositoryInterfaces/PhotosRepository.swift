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
	func saveImage(_ image: UIImage) throws -> String?
	func deleteImage(_ imageUrl: String) throws
	func getCameraPermission() -> AVAuthorizationStatus
	func reqeustCameraPermission() async -> AVAuthorizationStatus
}

public enum PhotosError: String, Error {
	case imageNotFound
	case failedToSaveImage
	case failedToDeleteImage
}

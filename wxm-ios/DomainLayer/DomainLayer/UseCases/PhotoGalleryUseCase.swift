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

	private let photosRepository: PhotosRepository

	public init(photosRepository: PhotosRepository) {
		self.photosRepository = photosRepository
	}

	public func saveImage(_ image: UIImage) throws -> String? {
		try photosRepository.saveImage(image)
	}

	public func deleteImage(_ imageUrl: String) throws {
		try photosRepository.deleteImage(imageUrl)
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

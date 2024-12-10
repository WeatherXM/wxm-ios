//
//  PhotoGalleryUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 10/12/24.
//

import Foundation
import UIKit

public struct PhotoGalleryUseCase: Sendable {

	private let photosRepository: PhotosRepository

	public init(photosRepository: PhotosRepository) {
		self.photosRepository = photosRepository
	}

	public func saveImage(_ image: UIImage) throws -> String? {
		try photosRepository.saveImage(image)
	}
}

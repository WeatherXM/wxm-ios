//
//  PhotosRepositoryImpl.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 10/12/24.
//

import Foundation
import DomainLayer
import UIKit
import Toolkit

private enum Constants: String {
	case folderName = "photos"
}

public struct PhotosRepositoryImpl: PhotosRepository {
	public init() {}
	
	public func saveImage(_ image: UIImage) throws -> String? {
		let fileName = self.folderPath.appendingPathComponent("image_\(UUID().uuidString).jpg")
		guard let data = image.jpegData(compressionQuality: 0.8) else {
			return nil
		}

		try data.write(to: fileName)

		return fileName.absoluteString
	}

	public func deleteImage(_ imageUrl: String) throws {
		guard let url = URL(string: imageUrl) else {
			return
		}

		if url.isFileURL, FileManager.default.fileExists(atPath: url.path) {
			try FileManager.default.removeItem(at: url)
			return
		} else if url.isHttp {
			// Delete from backend
		}

		throw PhotosError.failedToDeleteImage
	}
}

private extension PhotosRepositoryImpl {
	var folderPath: URL {
		var docUrl = FileManager.default.getDocumentsDirectory()
		docUrl.appendPathComponent(Constants.folderName.rawValue)
		docUrl.createDirectory()

		return docUrl
	}
}

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
import AVFoundation

private enum Constants: String {
	case folderName = "photos"
}

public struct PhotosRepositoryImpl: PhotosRepository {

	nonisolated(unsafe) private let locationManager = WXMLocationManager()

	public init() {}
	
	public func saveImage(_ image: UIImage, metadata: NSDictionary?) async throws -> String? {
		let fileName = self.folderPath.appendingPathComponent("image_\(UUID().uuidString).jpg")
		let fixedMetadata = await injectLocationInMetadata(metadata ?? .init())
		guard saveImageWithEXIF(image: image, metadata: fixedMetadata, saveFilename: fileName) else {
			return nil
		}

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

	public func getCameraPermission() -> AVAuthorizationStatus {
		AVCaptureDevice.authorizationStatus(for: .video)
	}

	public func reqeustCameraPermission() async -> AVAuthorizationStatus {
		await AVCaptureDevice.requestAccess(for: .video)
		return getCameraPermission()
	}

	public func purgeImages() throws {
		let folderPath = self.folderPath
		try FileManager.default.removeItem(at: folderPath)
	}
}

private extension PhotosRepositoryImpl {
	var folderPath: URL {
		var docUrl = FileManager.default.getDocumentsDirectory()
		docUrl.appendPathComponent(Constants.folderName.rawValue)
		docUrl.createDirectory()

		return docUrl
	}

	func saveImageWithEXIF(image: UIImage, metadata: NSDictionary?, saveFilename: URL) -> Bool {
		guard let data = image.jpegData(compressionQuality: 0.8) else {
			return false
		}

		let imageRef: CGImageSource = CGImageSourceCreateWithData((data as CFData), nil)!
		let uti: CFString = CGImageSourceGetType(imageRef)!
		let dataWithEXIF: NSMutableData = NSMutableData(data: data as Data)
		let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!

		CGImageDestinationAddImageFromSource(destination, imageRef, 0, (metadata ?? [:] as CFDictionary))
		CGImageDestinationFinalize(destination)

		let manager: FileManager = FileManager.default
		return manager.createFile(atPath: saveFilename.path(), contents: dataWithEXIF as Data, attributes: nil)
	}

	func injectLocationInMetadata(_ metadata: NSDictionary) async -> NSDictionary? {
		let result = await locationManager.getUserLocation()
		switch result {
			case .success(let location):
				let mutableDict = metadata.mutableCopy() as? NSMutableDictionary
				mutableDict?.setValue([kCGImagePropertyGPSLongitude: location.longitude, kCGImagePropertyGPSLatitude: location.latitude],
									  forKey: kCGImagePropertyGPSDictionary as String)
				return mutableDict
			case .failure(_):
				return metadata
		}
	}
}

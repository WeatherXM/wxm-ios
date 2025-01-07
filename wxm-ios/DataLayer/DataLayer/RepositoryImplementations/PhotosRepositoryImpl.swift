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
import Combine

private enum Constants: String {
	case folderName = "photos"
}

public struct PhotosRepositoryImpl: PhotosRepository {

	nonisolated(unsafe) private let locationManager = WXMLocationManager()
	nonisolated(unsafe) private let userDefaultsService = UserDefaultsService()
	private let fileUploader: FileUploaderService
	private let termsAcceptedKey = UserDefaults.GenericKey.arePhotoVerificationTermsAccepted.rawValue

	public var areTermsAccepted: Bool {
		let accepted: Bool? = userDefaultsService.get(key: termsAcceptedKey)
		return accepted == true
	}

	public var uploadProgressPublisher: AnyPublisher<Double?, Error> {
		fileUploader.totalProgressPublisher
	}

	public var uploadInProgressDeviceId: String? {
		fileUploader.getUploadInProgressDeviceId()
	}

	public init(fileUploader: FileUploaderService) {
		self.fileUploader = fileUploader
	}

	public func setTermsAccepted(_ termsAccepted: Bool) {
		userDefaultsService.save(value: termsAccepted, key: termsAcceptedKey)
	}

	public func saveImage(_ image: UIImage, metadata: NSDictionary?) async throws -> String? {
		let fileName = self.folderPath.appendingPathComponent("image_\(UUID().uuidString).jpg")
		let fixedMetadata = await injectLocationInMetadata(metadata ?? .init())
		guard saveImageWithEXIF(image: image, metadata: fixedMetadata, saveFilename: fileName) else {
			return nil
		}
		print("Image saved in \(fileName.path())")
		return fileName.absoluteString
	}

	public func deleteImage(_ imageUrl: String, deviceId: String) async throws {
		guard let url = URL(string: imageUrl) else {
			throw PhotosError.imageNotFound
		}

		if url.isFileURL, FileManager.default.fileExists(atPath: url.path) {
			try FileManager.default.removeItem(at: url)
			return
		} else if url.isHttp {
			// Delete from backend
			let photoId = url.lastPathComponent
			let builder = MeApiRequestBuilder.deleteUserDevicePhoto(deviceId: deviceId, photoId: photoId)
			let urlRequest = try builder.asURLRequest()
			let result: Result<EmptyEntity, NetworkErrorResponse> = try await ApiClient.shared.requestCodableAuthorized(urlRequest, mockFileName: builder.mockFileName).toAsync().result
			switch result {
				case .success:
					break
				case .failure(let error):
					throw PhotosError.networkError(error)
			}

			return
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

	public func startFilesUpload(deviceId: String, files: [URL]) async throws {
		let fileNames = files.map { $0.lastPathComponent }
		let resut = try await retrievePhotosUpload(for: deviceId, names: fileNames)
		switch resut {
			case .success(let objects):
				for (index, element) in files.enumerated() {
					if let uploadUrl = objects[index].url,
					   let url = URL(string: uploadUrl) {
						try fileUploader.uploadFile(file: element, to: url, for: deviceId)
					}
				}
			case .failure(let error):
				throw PhotosError.networkError(error)
		}
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

	func retrievePhotosUpload(for deviceId: String, names: [String]) async throws -> Result<[NetworkPostDevicePhotosResponse], NetworkErrorResponse> {
		let builder = MeApiRequestBuilder.postPhotoNames(deviceId: deviceId, photos: names)
		let urlRequest = try builder.asURLRequest()
		return try await ApiClient.shared.requestCodableAuthorized(urlRequest,
																   mockFileName: builder.mockFileName).toAsync().result
	}
}

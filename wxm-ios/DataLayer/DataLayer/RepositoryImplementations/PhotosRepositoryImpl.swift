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

	nonisolated(unsafe) private let locationManager: WXMLocationManager.LocationManagerProtocol
	nonisolated(unsafe) private let userDefaultsService = UserDefaultsService()
	private let fileUploader: FileUploaderService
	private let termsAcceptedKey = UserDefaults.GenericKey.arePhotoVerificationTermsAccepted.rawValue

	public var areTermsAccepted: Bool {
		let accepted: Bool? = userDefaultsService.get(key: termsAcceptedKey)
		return accepted == true
	}

	public var uploadProgressPublisher: AnyPublisher<(String, Double?), Never> {
		fileUploader.totalProgressPublisher
	}

	public var uploadErrorPublisher: AnyPublisher<(String, Error), Never> {
		fileUploader.uploadErrorPublisher
	}

	public var uploadCompletedPublisher: AnyPublisher<(String, Int), Never> {
		fileUploader.uploadCompletedPublisher
	}

	public var uploadStartedPublisher: AnyPublisher<String, Never> {
		fileUploader.uploadStartedPublisher
	}

	public init(fileUploader: FileUploaderService, locationManager: WXMLocationManager.LocationManagerProtocol) {
		self.fileUploader = fileUploader
		self.locationManager = locationManager
	}

	public func setTermsAccepted(_ termsAccepted: Bool) {
		userDefaultsService.save(value: termsAccepted, key: termsAcceptedKey)
	}

	public func getUploadInProgressDeviceId() -> String? {
		fileUploader.getUploadInProgressDeviceId()
	}

	public func saveImage(_ image: UIImage, deviceId: String, metadata: NSDictionary?, userComment: String) async throws -> String? {
		let fileName = self.getFolderPath(for: deviceId).appendingPathComponent("\(UUID().uuidString).jpg")
		var fixedMetadata = await injectLocationInMetadataIfNeeded(metadata ?? .init()) ?? .init()
		fixedMetadata = injectUserCommentInMetadata(fixedMetadata, comment: userComment) ?? .init()
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
					NotificationCenter.default.post(name: .devicePhotoDeleted, object: deviceId)
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

	public func requestCameraPermission() async -> AVAuthorizationStatus {
		await AVCaptureDevice.requestAccess(for: .video)
		return getCameraPermission()
	}

	public func purgeImages() throws {
		let folderPath = self.folderPath
		try FileManager.default.removeItem(at: folderPath)
	}

	public func clearLocalImages(deviceId: String) throws {
		let folderPath = self.getFolderPath(for: deviceId)
		try FileManager.default.removeItem(at: folderPath)
	}

	public func startFilesUpload(deviceId: String, files: [URL]) async throws {
		let fileNames = files.map { $0.lastPathComponent }
		let resut = try await retrievePhotosUpload(for: deviceId, names: fileNames)
		switch resut {
			case .success(let objects):
				try fileUploader.uploadFiles(files: files, to: objects, for: deviceId)
			case .failure(let error):
				throw PhotosError.networkError(error)
		}
	}

	public func retryFilesUpload(deviceId: String) async throws {
		let contents = try FileManager.default.contentsOfDirectory(atPath: getFolderPath(for: deviceId).path())
		let fileUrls = contents.map { getFolderPath(for: deviceId).appending(path: $0) }
		try await startFilesUpload(deviceId: deviceId, files: fileUrls)
	}

	public func cancelUpload(deviceId: String) {
		fileUploader.cancelUpload(for: deviceId)
	}

	public func getUploadState(deviceId: String) -> PhotoUploadState? {
		let state = fileUploader.getUploadState(for: deviceId)
		return state?.toPhotoUploadState
	}
}

private extension PhotosRepositoryImpl {
	var folderPath: URL {
		var docUrl = FileManager.default.getDocumentsDirectory()
		docUrl.appendPathComponent(Constants.folderName.rawValue)
		docUrl.createDirectory()

		return docUrl
	}

	func getFolderPath(for deviceId: String) -> URL {
		let url = folderPath.appendingPathComponent(deviceId)
		url.createDirectory()

		return url
	}

	func saveImageWithEXIF(image: UIImage, metadata: NSDictionary?, saveFilename: URL) -> Bool {
		let scaledImage = image.scaleDown(newWidth: 1920.0)
		// Update metadata with the correct orientation
		var metadata = metadata?.mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
		metadata[kCGImagePropertyOrientation] = CGImagePropertyOrientation(scaledImage.imageOrientation).rawValue

		guard let data = scaledImage.jpegData(compressionQuality: 1.0),
			  let imageRef: CGImageSource = CGImageSourceCreateWithData((data as CFData), nil),
			  let uti: CFString = CGImageSourceGetType(imageRef),
			  case let dataWithEXIF: NSMutableData = NSMutableData(data: data as Data),
			  let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil) else {
			return false
		}

		CGImageDestinationAddImageFromSource(destination, imageRef, 0, (metadata))
		CGImageDestinationFinalize(destination)

		let manager: FileManager = FileManager.default
		return manager.createFile(atPath: saveFilename.path(), contents: dataWithEXIF as Data, attributes: nil)
	}

	func injectLocationInMetadataIfNeeded(_ metadata: NSDictionary) async -> NSDictionary? {
		let gpsDict = metadata[kCGImagePropertyGPSDictionary] as? NSDictionary
		guard gpsDict?[kCGImagePropertyGPSLongitude] == nil || gpsDict?[kCGImagePropertyGPSLatitude] == nil else {
			return metadata
		}

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

	func injectUserCommentInMetadata(_ metadata: NSDictionary, comment: String) -> NSDictionary? {
		let mutableMetadata = metadata.mutableCopy() as? NSMutableDictionary
		let exifDict = mutableMetadata?[kCGImagePropertyExifDictionary] as? NSMutableDictionary ?? NSMutableDictionary()
		exifDict[kCGImagePropertyExifUserComment] = comment
		mutableMetadata?[kCGImagePropertyExifDictionary] = exifDict

		return mutableMetadata
	}

	func retrievePhotosUpload(for deviceId: String, names: [String]) async throws -> Result<[NetworkPostDevicePhotosResponse], NetworkErrorResponse> {
		let builder = MeApiRequestBuilder.postPhotoNames(deviceId: deviceId, photos: names)
		let urlRequest = try builder.asURLRequest()
		return try await ApiClient.shared.requestCodableAuthorized(urlRequest,
																   mockFileName: builder.mockFileName).toAsync().result
	}
}

private extension FileUploaderService.UploadState {
	var toPhotoUploadState: PhotoUploadState {
		switch self {
			case .uploading(let progress):
				return .uploading(progress)
			case .failed:
				return .failed
		}
	}
}

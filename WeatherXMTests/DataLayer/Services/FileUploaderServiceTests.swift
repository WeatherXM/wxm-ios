//
//  FileUploaderServiceTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 6/2/25.
//

import Testing
@testable import DataLayer
import DomainLayer
import Toolkit

@Suite(.serialized)
struct FileUploaderServiceTests {

	private let fileUploaderService: FileUploaderService
	private let mockFileURL: URL?
	private let cancellableWrapper = CancellableWrapper()
	private let postDataResponse: NetworkPostDevicePhotosResponse = .init(url: FileUploadMockProtocol.successUrl, fields: nil)
	private let postDataFailResponse: NetworkPostDevicePhotosResponse = .init(url: FileUploadMockProtocol.failUrl, fields: nil)
	private let deviceId = "123"

	init() throws {
		let documentsDirectory = FileManager.documentsDirectory
		if let path = Bundle(for: BundleAccessor.self).path(forResource: "dummy_image", ofType: "png"),
		   let filePath = documentsDirectory?.appendingPathComponent("dummy_image_temp.png") {
			try FileManager.default.copyItem(at: URL(fileURLWithPath: path), to: filePath)
			mockFileURL = filePath
		} else {
			mockFileURL = nil
		}
		fileUploaderService = FileUploaderService(mock: true)
	}

	@Test func started() async throws {
		try await confirmation { confim in
			fileUploaderService.uploadStartedPublisher.sink { _ in
				#expect(fileUploaderService.getUploadState(for: deviceId) != nil)
				#expect(fileUploaderService.getUploadInProgressDeviceId() == deviceId)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)

			try fileUploaderService.uploadFiles(files: [self.mockFileURL!], to: [postDataResponse], for: "123")
			#expect(fileUploaderService.getUploadInProgressDeviceId() == deviceId)
			#expect(fileUploaderService.getUploadState(for: deviceId) != nil)
			try await Task.sleep(for: .seconds(2))
		}
	}

	@Test func completed() async throws {
		try await confirmation { confim in
			fileUploaderService.uploadCompletedPublisher.sink { _, _ in
				#expect(fileUploaderService.getUploadState(for: deviceId) == nil)
				#expect(fileUploaderService.getUploadInProgressDeviceId() == nil)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)

			try fileUploaderService.uploadFiles(files: [self.mockFileURL!], to: [postDataResponse], for: deviceId)			
			#expect(fileUploaderService.getUploadState(for: deviceId) != nil)
			#expect(fileUploaderService.getUploadInProgressDeviceId() == deviceId)
			try await Task.sleep(for: .seconds(2))
		}
    }

	@Test func progress() async throws {
		try await confirmation(expectedCount: 3) { confim in
			fileUploaderService.totalProgressPublisher.sink { _, _ in
				#expect(fileUploaderService.getUploadState(for: deviceId) != nil)
				#expect(fileUploaderService.getUploadInProgressDeviceId() == deviceId)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)

			try fileUploaderService.uploadFiles(files: [self.mockFileURL!], to: [postDataResponse], for: deviceId)
			#expect(fileUploaderService.getUploadState(for: deviceId) != nil)
			#expect(fileUploaderService.getUploadInProgressDeviceId() == deviceId)
			try await Task.sleep(for: .seconds(2))
		}
	}

	@Test func failure() async throws {
		try await confirmation { confim in
			fileUploaderService.uploadErrorPublisher.sink { _, _ in
				#expect(fileUploaderService.getUploadState(for: deviceId) == .failed)
				#expect(fileUploaderService.getUploadInProgressDeviceId() == deviceId)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)

			try fileUploaderService.uploadFiles(files: [self.mockFileURL!], to: [postDataFailResponse], for: deviceId)
			try await Task.sleep(for: .seconds(2))
		}
	}
}

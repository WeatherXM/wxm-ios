//
//  PhotoGalleryUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 6/3/25.
//

import Testing
@testable import DomainLayer
import Toolkit
import UIKit

struct PhotoGalleryUseCaseTests {
	let repository: MockPhotosRepositoryImpl = .init()
	let useCase: PhotoGalleryUseCase
	private var cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = .init(photosRepository: repository)
	}

    @Test func uploadInProgressId() {
		#expect(useCase.getUploadInProgressDeviceId() == repository.getUploadInProgressDeviceId())
    }

	@Test func termsAccepted() {
		#expect(!useCase.areTermsAccepted)
		repository.setTermsAccepted(true)
		#expect(useCase.areTermsAccepted)
	}

	@Test func saveImage() async throws {
		let fileName = try await useCase.saveImage(UIImage(),
												   deviceId: "124",
												   metadata: nil,
												   userComment: "")

		let repositoryFileName = try await repository.saveImage(UIImage(),
																deviceId: "124",
																metadata: nil,
																userComment: "")
		#expect(fileName == repositoryFileName)
	}

	@Test func deleteImage() async throws {
		#expect(!repository.isImageDeleted)
		try await useCase.deleteImage("", deviceId: "")
		#expect(repository.isImageDeleted)
	}

	@Test func cameraPermission() {
		let permission = useCase.getCameraPermission()
		let repositoryPermission = repository.getCameraPermission()
		#expect(permission == repositoryPermission)
	}

	@Test func purge() throws {
		#expect(!repository.areImagesPurged)
		try useCase.purgeImages()
		#expect(repository.areImagesPurged)
	}

	@Test func clearLocalImages() throws {
		#expect(!repository.areLocalImagesCleared)
		try useCase.clearLocalImages(deviceId: "")
		#expect(repository.areLocalImagesCleared)
	}

	@Test func startFileUpload() async throws {
		#expect(!repository.uploadStarted)
		try await useCase.startFilesUpload(deviceId: "", files: [])
		#expect(repository.uploadStarted)
	}

	@Test func retryUpload() async throws {
		#expect(!repository.retryUploadStarted)
		try await useCase.retryUpload(deviceId: "")
		#expect(repository.retryUploadStarted)
	}

	@Test func cancelUpload() async throws {
		#expect(!repository.uploadCancelled)
		useCase.cancelUpload(deviceId: "")
		#expect(repository.uploadCancelled)
	}

	@Test func getUploadState() {
		let state = useCase.getUploadState(deviceId: "")
		let repositoryState = repository.getUploadState(deviceId: "")
		#expect(state == repositoryState)
	}

	@Test func uploadProgressPulisher() async throws {
		try await confirmation { confim in
			useCase.uploadProgressPublisher.sink { deviceId, progress  in
				#expect(deviceId == "124")
				#expect(progress == 67.0)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)
			repository.sendUploadProgress("124", 67.0)
			try await Task.sleep(for: .seconds(1))
		}
	}

	@Test func uploadErrorPulisher() async throws {
		let uploadError = NSError(domain: "", code: 1)
		try await confirmation { confim in
			useCase.uploadErrorPublisher.sink { deviceId, error  in
				#expect(deviceId == "124")
				#expect(error as NSError == uploadError)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)

			repository.sendUploadError("124", uploadError)
			try await Task.sleep(for: .seconds(1))
		}
	}

	@Test func uploadCompletedPulisher() async throws {
		try await confirmation { confim in
			useCase.uploadCompletedPublisher.sink { deviceId, count in
				#expect(deviceId == "124")
				#expect(count == 4)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)
			repository.sendUploadCompleted("124", 4)
			try await Task.sleep(for: .seconds(1))
		}
	}

	@Test func uploadStartedPulisher() async throws {
		try await confirmation { confim in
			useCase.uploadStartedPublisher.sink { deviceId in
				#expect(deviceId == "124")
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)
			repository.sendUploadStarted("124")
			try await Task.sleep(for: .seconds(1))
		}
	}
}

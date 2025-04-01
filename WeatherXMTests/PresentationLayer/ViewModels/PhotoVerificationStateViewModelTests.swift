//
//  PhotoVerificationStateViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Testing
import Foundation
@testable import WeatherXM

@MainActor
struct PhotoVerificationStateViewModelTests {
	let viewModel: PhotoVerificationStateViewModel
	let photoGalleryUseCase: MockPhotoGalleryUseCase
	let deviceInfoUseCase: MockDeviceInfoUseCase

	init() {
		deviceInfoUseCase = .init()
		photoGalleryUseCase = .init()
		viewModel = .init(deviceId: "124", deviceInfoUseCase: deviceInfoUseCase, photoGalleryUseCase: photoGalleryUseCase)
	}

    @Test func initialState() async throws {
		#expect(viewModel.state == .content(photos: [], isFailed: false))
		let refreshError = await viewModel.refresh()
		#expect(refreshError == nil)
		#expect(viewModel.state == .content(photos: [URL(string: "http://image.com")!], isFailed: false))
	}

	@Test func cancelUpload() {
		#expect(photoGalleryUseCase.uploadCanceled == false)
		viewModel.handleCancelUploadTap(showAlert: false)
		#expect(photoGalleryUseCase.uploadCanceled == true)
	}

	@Test func retryUpload() async throws {
		#expect(photoGalleryUseCase.uploadRetried == false)
		viewModel.retryUpload()
		try await Task.sleep(for: .seconds(1))
		#expect(photoGalleryUseCase.uploadRetried == true)
	}
}

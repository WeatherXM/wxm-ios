//
//  GalleryViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

import Testing
@testable import WeatherXM
import SwiftUI

@MainActor
struct GalleryViewModelTests {
	let viewModel: GalleryViewModel
	let linkNavigator: MockLinkNavigation
	let useCase: MockPhotoGalleryUseCase

	init() {
		useCase = MockPhotoGalleryUseCase()
		linkNavigator = MockLinkNavigation()
		viewModel = GalleryViewModel(deviceId: "124",
									 images: ["http://image.com"],
									 photoGalleryUseCase: useCase,
									 isNewPhotoVerification: false,
									 linkNavigation: linkNavigator)
	}

	@Test func initialState() async throws {
		#expect(viewModel.subtitle == LocalizableString.PhotoVerification.morePhotosToUpload(1).localized)
		#expect(viewModel.images.count == 1)
		#expect(viewModel.selectedImage == viewModel.images.first)
		#expect(viewModel.isCameraDenied == false)
		#expect(viewModel.shareImages?.isEmpty == true)
		#expect(viewModel.localImages?.isEmpty == true)
		#expect(viewModel.isPlusButtonEnabled)
		#expect(!viewModel.isUploadButtonEnabled)
		#expect(viewModel.backButtonIcon == .arrowLeft)
	}

	@Test func delete() async throws {
		#expect(!useCase.imageDeleted)
		#expect(viewModel.selectedImage == viewModel.images.first)

		viewModel.handleDeleteButtonTap(showAlert: false)

		try await Task.sleep(for: .seconds(1))

		#expect(useCase.imageDeleted)
		#expect(viewModel.images.isEmpty)
		#expect(viewModel.selectedImage == nil)
	}

	@Test func upload() async throws {
		#expect(!useCase.fileUploadStarted)
		#expect(viewModel.selectedImage == viewModel.images.first)

		viewModel.handleUploadButtonTap(dismissAction: nil, showAlert: false)

		try await Task.sleep(for: .seconds(1))

		#expect(useCase.fileUploadStarted)
		#expect(!viewModel.images.isEmpty)
		#expect(viewModel.selectedImage == viewModel.images.first)
	}

	@Test func openSettings() {
		#expect(linkNavigator.openedUrl == nil)
		viewModel.handleOpenSettingsTap()
		#expect(linkNavigator.openedUrl == UIApplication.openSettingsURLString)
	}
}

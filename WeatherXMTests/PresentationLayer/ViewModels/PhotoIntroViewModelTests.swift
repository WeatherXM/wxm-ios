//
//  PhotoIntroViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

import Testing
@testable import WeatherXM

@MainActor
struct PhotoIntroViewModelTests {
	let viewModel: PhotoIntroViewModel
	let useCase: MockPhotoGalleryUseCase

	init() {
		useCase = MockPhotoGalleryUseCase()
		viewModel = PhotoIntroViewModel(deviceId: "124", images: [], photoGalleryUseCase: useCase)

	}

    @Test func acceptTerms() async throws {
		#expect(useCase.areTermsAccepted == false)
		#expect(viewModel.areTermsAccepted == false)
		viewModel.areTermsAccepted = true
		#expect(useCase.areTermsAccepted == true)
		#expect(viewModel.areTermsAccepted == true)
    }
}

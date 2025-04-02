//
//  AnalyticsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM

struct AnalyticsViewModelTests {
	let viewModel: AnalyticsViewModel
	let useCase: MockSettingsUseCase

	init() {
		useCase = .init()
		viewModel = .init(useCase: useCase)
	}

    @Test func deny() {
		#expect(useCase.isAnalyticsEnabled == false)
		viewModel.denyButtonTapped()
		#expect(useCase.isAnalyticsEnabled == false)
    }

	@Test func soundsGood() {
		#expect(useCase.isAnalyticsEnabled == false)
		viewModel.soundsGoodButtonTapped()
		#expect(useCase.isAnalyticsEnabled == true)
	}
}

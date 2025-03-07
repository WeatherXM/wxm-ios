//
//  SettingsUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Testing
@testable import DomainLayer

struct SettingsUseCaseTests {
	let settingsRepository: MockSettingsRepositoryImpl = .init()
	let useCase: SettingsUseCase

	init() {
		self.useCase = .init(repository: settingsRepository)
	}

	@Test func initialize() {
		#expect(!useCase.isAnalyticsOptSet)
		useCase.initializeAnalyticsTracking()
		#expect(useCase.isAnalyticsOptSet)
    }

	@Test func optInOutAnalytics() {
		#expect(!useCase.isAnalyticsEnabled)
		useCase.optInOutAnalytics(true)
		#expect(useCase.isAnalyticsEnabled)
		useCase.optInOutAnalytics(false)
		#expect(!useCase.isAnalyticsEnabled)
	}
}

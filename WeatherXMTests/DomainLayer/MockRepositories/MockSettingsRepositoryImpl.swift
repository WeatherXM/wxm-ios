//
//  MockSettingsRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Foundation
@testable import DomainLayer

class MockSettingsRepositoryImpl {
	private var isAnalyticsEnabledValue: Bool = false
	private var isAnalyticsSetValue: Bool = false
}

extension MockSettingsRepositoryImpl: SettingsRepository {
	var isAnalyticsEnabled: Bool {
		isAnalyticsEnabledValue
	}
	
	var isAnalyticsOptSet: Bool {
		isAnalyticsSetValue
	}
	
	func initializeAnalytics() {
		isAnalyticsSetValue = true
	}
	
	func optInOutAnalytics(_ option: Bool) {
		isAnalyticsEnabledValue = option
	}
}

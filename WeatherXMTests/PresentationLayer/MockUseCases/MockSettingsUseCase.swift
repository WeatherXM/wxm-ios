//
//  MockSettingsUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Foundation
import DomainLayer

final class MockSettingsUseCase: SettingsUseCaseApi {
	nonisolated(unsafe) var isAnalyticsEnabled: Bool = false
	nonisolated(unsafe) var isAnalyticsOptSet: Bool = false

	func initializeAnalyticsTracking() {
		isAnalyticsOptSet = true
	}

	func optInOutAnalytics(_ option: Bool) {
		isAnalyticsEnabled = option
	}
}

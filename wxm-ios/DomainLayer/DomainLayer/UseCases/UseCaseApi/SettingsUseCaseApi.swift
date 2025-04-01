//
//  SettingsUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Foundation

public protocol SettingsUseCaseApi: Sendable {
	var isAnalyticsEnabled: Bool { get }
	var isAnalyticsOptSet: Bool { get }

	func initializeAnalyticsTracking()
	func optInOutAnalytics(_ option: Bool)
}

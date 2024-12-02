//
//  WXMAnalytics.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 28/2/23.
//

import Foundation

public class WXMAnalytics: @unchecked Sendable {
    public static let shared = WXMAnalytics()
	private var providers: [AnalyticsProviderImplementation] = []

    private init() {}

	public func launch(with analyticsProviders: [AnalyticsProvider]) {
		if disableAnalytics {
			providers = [MockAnalytics()]
		} else {
			providers = analyticsProviders.map { $0.provider }
		}
	}
}

// MARK: - Analytics
public extension WXMAnalytics {

	func setAnalyticsCollectionEnabled(_ enabled: Bool) {
		providers.forEach { $0.setAnalyticsCollectionEnabled(enabled) }
	}

    func trackScreen(_ screen: Screen, parameters: [Parameter: ParameterValue]? = nil) {
		providers.forEach { $0.trackScreen(screen, parameters: parameters) }
    }

    func trackEvent(_ event: Event, parameters: [Parameter: ParameterValue]?) {
		providers.forEach { $0.trackEvent(event, parameters: parameters) }
    }

    func setUserId(_ userId: String?) {
		providers.forEach { $0.setUserId(userId) }
    }

    func setUserProperty(key: Parameter, value: ParameterValue) {
		providers.forEach { $0.setUserProperty(key: key, value: value) }
    }

	func removeUserProperty(key: Parameter) {
		providers.forEach { $0.removeUserProperty(key: key) }
	}

    func setDefaultParameter(key: Parameter, value: ParameterValue) {
		providers.forEach { $0.setDefaultParameter(key: key, value: value) }
    }
}

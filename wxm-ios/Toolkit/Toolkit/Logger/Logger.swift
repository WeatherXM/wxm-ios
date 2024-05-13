//
//  Logger.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 28/2/23.
//

import Firebase
import Foundation
import FirebaseAnalytics

public class Logger {
    public static let shared = Logger()
	private var providers: [AnalyticsProviderImplementation] = []

    private init() {}

	public func launch(with analyticsProviders: [AnalyticsProvider]) {
		if disableFirebase {
			providers = [MockAnalytics()]
		} else {
			providers = analyticsProviders.map { $0.provider }
		}
	}
}

// MARK: - Errors
public extension Logger {
	func logNetworkError(_ networkError: NetworkError) {
		providers.forEach { $0.logNetworkError(networkError) }
	}

	func logError(_ nsError: NSError) {
		providers.forEach { $0.logError(nsError) }
	}
}

// MARK: - Analytics
public extension Logger {

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

    func setDefaultParameter(key: Parameter, value: ParameterValue) {
		providers.forEach { $0.setDefaultParameter(key: key, value: value) }
    }
}

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
    private let networkDomain = "network_domain"

    public static let shared = Logger()
	private let loggerImpl: LoggerImplementation

    private init() {
		if disableFirebase {
			loggerImpl = MockLogger()
		} else {
			loggerImpl = RemoteLogger()
		}
	}
}

// MARK: - Errors
public extension Logger {
	func logNetworkError(_ networkError: NetworkError) {
		loggerImpl.logNetworkError(networkError)
	}

	func logError(_ nsError: NSError) {
		loggerImpl.logError(nsError)
	}
}

// MARK: - Analytics
public extension Logger {

	func setAnalyticsCollectionEnabled(_ enabled: Bool) {
		loggerImpl.setAnalyticsCollectionEnabled(enabled)
	}

    func trackScreen(_ screen: Screen, parameters: [Parameter: ParameterValue]? = nil) {
		loggerImpl.trackScreen(screen, parameters: parameters)
    }

    func trackEvent(_ event: Event, parameters: [Parameter: ParameterValue]?) {
		loggerImpl.trackEvent(event, parameters: parameters)
    }

    func setUserId(_ userId: String?) {
		loggerImpl.setUserId(userId)
    }

    func setUserProperty(key: Parameter, value: ParameterValue) {
		loggerImpl.setUserProperty(key: key, value: value)
    }

    func setDefaultParameter(key: Parameter, value: ParameterValue) {
		loggerImpl.setDefaultParameter(key: key, value: value)
    }
}

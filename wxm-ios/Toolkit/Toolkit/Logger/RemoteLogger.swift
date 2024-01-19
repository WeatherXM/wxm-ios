//
//  RemoteLogger.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 18/12/23.
//

import Foundation
import Firebase
import FirebaseAnalytics

struct RemoteLogger: LoggerImplementation {
	private let networkDomain = "network_domain"

	func logNetworkError(_ networkError: NetworkError) {
		let nsError = NSError(domain: networkDomain,
							  code: networkError.code,
							  userInfo: networkError.userInfo)
		logError(nsError)
	}

	func logError(_ nsError: NSError) {
		Crashlytics.crashlytics().record(error: nsError)
	}

	func trackScreen(_ screen: Screen, parameters: [Parameter : ParameterValue]?) {
		var params: [String: Any] = [AnalyticsParameterScreenName: screen.rawValue]
		if let additionalParams = parameters?.toEventParamsDictionary {
			params += additionalParams
		}

		Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
	}

	func trackEvent(_ event: Event, parameters: [Parameter : ParameterValue]?) {
		let convertedParams: [String: Any]? = parameters?.toEventParamsDictionary
		Analytics.logEvent(event.description, parameters: convertedParams)
	}

	func setUserId(_ userId: String?) {
		Analytics.setUserID(userId)
		Crashlytics.crashlytics().setUserID(userId)
	}

	func setUserProperty(key: Parameter, value: ParameterValue) {
		Analytics.setUserProperty(value.rawValue, forName: key.description)
	}

	func setDefaultParameter(key: Parameter, value: ParameterValue) {
		Analytics.setDefaultEventParameters([key.description: value.rawValue])
	}
}

private extension Dictionary where Key == Parameter, Value == ParameterValue {
	var toEventParamsDictionary: [String: Any]? {
		let convertedParams: [String: Any] = self.reduce(into: [:]) { $0[$1.key.description] = $1.value.rawValue }
		return convertedParams
	}
}


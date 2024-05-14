//
//  FirebaseAnalytics.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 13/5/24.
//

import Foundation
import Firebase
import FirebaseAnalytics


struct FirebaseAnalytics: AnalyticsProviderImplementation {

	func trackScreen(_ screen: Screen, parameters: [Parameter : ParameterValue]?) {
		var params: [String: Any] = [AnalyticsParameterScreenName: screen.rawValue]
		if let additionalParams = parameters?.toEventParamsDictionary {
			params += additionalParams
		}

		Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
	}

	func trackEvent(_ event: Event, parameters: [Parameter : ParameterValue]?) {
		Analytics.logEvent(event.description, 
						   parameters: parameters?.toEventParamsDictionary)
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

	func setAnalyticsCollectionEnabled(_ enabled: Bool) {
		FirebaseManager.shared.setAnalyticsCollectionEnabled(enabled)
	}
}

private extension Dictionary where Key == Parameter, Value == ParameterValue {
	var toEventParamsDictionary: [String: Any]? {
		let convertedParams: [String: Any] = self.reduce(into: [:]) { $0[$1.key.description] = $1.value.rawValue }
		return convertedParams
	}
}

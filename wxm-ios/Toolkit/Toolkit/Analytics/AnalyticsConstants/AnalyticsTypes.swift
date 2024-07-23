//
//  AnalyticsTypes.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 13/5/24.
//

import Foundation

public enum AnalyticsProvider {
	case firebase
	case mixpanel(String)
}

extension AnalyticsProvider {
	var provider: AnalyticsProviderImplementation {
		switch self {
			case .firebase:
				FirebaseAnalytics()
			case .mixpanel(let mixpanelId):
				MixpanelAnalytics(mixpanelId: mixpanelId)
		}
	}
}

protocol AnalyticsProviderImplementation {
	func trackScreen(_ screen: Screen, parameters: [Parameter: ParameterValue]?)
	func trackEvent(_ event: Event, parameters: [Parameter: ParameterValue]?)
	func setUserId(_ userId: String?)
	func setUserProperty(key: Parameter, value: ParameterValue)
	func removeUserProperty(key: Parameter)
	func setDefaultParameter(key: Parameter, value: ParameterValue)
	func setAnalyticsCollectionEnabled(_ enabled: Bool)
}

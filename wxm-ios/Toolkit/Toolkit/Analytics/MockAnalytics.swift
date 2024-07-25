//
//  MockAnalytics.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 18/12/23.
//

import Foundation

struct MockAnalytics: AnalyticsProviderImplementation {
	func logNetworkError(_ networkError: NetworkError) {}
	func logError(_ nsError: NSError) {}
	func trackScreen(_ screen: Screen, parameters: [Parameter: ParameterValue]?) {}
	func trackEvent(_ event: Event, parameters: [Parameter: ParameterValue]?) {}
	func setUserId(_ userId: String?) {}
	func setUserProperty(key: Parameter, value: ParameterValue) {}
	func removeUserProperty(key: Parameter) {}
	func setDefaultParameter(key: Parameter, value: ParameterValue) {}
	func setAnalyticsCollectionEnabled(_ enabled: Bool) {}
}

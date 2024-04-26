//
//  LoggerTypes.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 1/3/23.
//

import Foundation

public protocol NetworkError: Error {
    var code: Int { get }
    var userInfo: [String: Any]? { get }
}

protocol LoggerImplementation {
	func logNetworkError(_ networkError: NetworkError)
	func logError(_ nsError: NSError)
	func trackScreen(_ screen: Screen, parameters: [Parameter: ParameterValue]?)
	func trackEvent(_ event: Event, parameters: [Parameter: ParameterValue]?)
	func setUserId(_ userId: String?)
	func setUserProperty(key: Parameter, value: ParameterValue)
	func setDefaultParameter(key: Parameter, value: ParameterValue)
	func setAnalyticsCollectionEnabled(_ enabled: Bool)
}

//
//  RemoteLogger.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 18/12/23.
//

import Foundation
import Firebase
import FirebaseAnalytics
import Mixpanel

private let mixpanelSuperParams: Properties = [Parameter.appId.rawValue: Bundle.main.bundleIdentifier]

struct RemoteLogger: LoggerImplementation {
	private let networkDomain = "network_domain"
	private var mixpanelInstance: MixpanelInstance?

	func launch(with mixpanelId: String) {
		Mixpanel.initialize(token: mixpanelId, trackAutomaticEvents: false)
		resetMixpanel()
		Mixpanel.mainInstance().loggingEnabled = true
	}
	
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
		Analytics.logEvent(event.description, parameters: parameters?.toEventParamsDictionary)
		Mixpanel.mainInstance().track(event: event.description, properties: parameters?.toMixpanelParamsDictionary)
	}

	func setUserId(_ userId: String?) {
		Analytics.setUserID(userId)
		Crashlytics.crashlytics().setUserID(userId)
		
		if let userId {
			Mixpanel.mainInstance().identify(distinctId: userId)
		} else {
			resetMixpanel()
		}
	}

	func setUserProperty(key: Parameter, value: ParameterValue) {
		Analytics.setUserProperty(value.rawValue, forName: key.description)
		Mixpanel.mainInstance().people.set(property: key.description, to: value.rawValue)
	}

	func setDefaultParameter(key: Parameter, value: ParameterValue) {
		Analytics.setDefaultEventParameters([key.description: value.rawValue])
		addMixpanelSuperProperties(properties: [key: value].toMixpanelParamsDictionary ?? [:])
	}

	func setAnalyticsCollectionEnabled(_ enabled: Bool) {
		FirebaseManager.shared.setAnalyticsCollectionEnabled(enabled)

		if enabled {
			Mixpanel.mainInstance().optInTracking()
		} else {
			Mixpanel.mainInstance().optOutTracking()
		}
	}
}

private extension RemoteLogger {
	func addMixpanelSuperProperties(properties: Properties) {
		var currentProperties: Properties = Mixpanel.mainInstance().currentSuperProperties() as? Properties ?? [:]
		currentProperties += properties
		Mixpanel.mainInstance().registerSuperProperties(currentProperties)
	}

	func resetMixpanel() {
		Mixpanel.mainInstance().reset()
		addMixpanelSuperProperties(properties: mixpanelSuperParams)
	}
}

private extension Dictionary where Key == Parameter, Value == ParameterValue {
	var toEventParamsDictionary: [String: Any]? {
		let convertedParams: [String: Any] = self.reduce(into: [:]) { $0[$1.key.description] = $1.value.rawValue }
		return convertedParams
	}

	var toMixpanelParamsDictionary: [String: MixpanelType]? {
		let convertedParams: [String: MixpanelType] = self.reduce(into: [:]) { $0[$1.key.description] = $1.value.rawValue }
		return convertedParams
	}
}


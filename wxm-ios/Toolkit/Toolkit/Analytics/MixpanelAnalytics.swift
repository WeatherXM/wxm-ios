//
//  MixpanelAnalytics.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 13/5/24.
//

import Foundation
import Mixpanel

struct MixpanelAnalytics: AnalyticsProviderImplementation {
	private var mixpanelInstance: MixpanelInstance?
	private let mixpanelSuperParams: Properties = [Parameter.appId.rawValue: Bundle.main.bundleIdentifier]

	init(mixpanelId: String) {
		Mixpanel.initialize(token: mixpanelId, trackAutomaticEvents: false)
		Mixpanel.mainInstance().loggingEnabled = true
		addMixpanelSuperProperties(properties: mixpanelSuperParams)
	}

	func trackScreen(_ screen: Screen, parameters: [Parameter: ParameterValue]?) {
		var params: [String: MixpanelType] = [analyticsScreenNameKey: screen.rawValue]
		if let additionalParams = parameters?.toMixpanelParamsDictionary {
			params += additionalParams
		}
		Mixpanel.mainInstance().track(event: analyticsScreenView,
									  properties: params)
	}

	func trackEvent(_ event: Event, parameters: [Parameter: ParameterValue]?) {
		Mixpanel.mainInstance().track(event: event.description,
									  properties: parameters?.toMixpanelParamsDictionary)
	}

	func setUserId(_ userId: String?) {
		guard let userId else {
			return
		}

		Mixpanel.mainInstance().identify(distinctId: userId)
	}

	func setUserProperty(key: Parameter, value: ParameterValue) {
		Mixpanel.mainInstance().people.set(property: key.description, to: value.rawValue)
	}

	func removeUserProperty(key: Parameter) {
		Mixpanel.mainInstance().people.unset(properties: [key.description])
	}

	func setDefaultParameter(key: Parameter, value: ParameterValue) {
		addMixpanelSuperProperties(properties: [key: value].toMixpanelParamsDictionary ?? [:])
	}

	func setAnalyticsCollectionEnabled(_ enabled: Bool) {
		if !enabled {
			Mixpanel.mainInstance().optOutTracking()
		} else if enabled, Mixpanel.mainInstance().hasOptedOutTracking() {
			Mixpanel.mainInstance().optInTracking()
		}
	}

	func userLoggedOut() {
		resetMixpanel()
	}
}

private extension MixpanelAnalytics {
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
	var toMixpanelParamsDictionary: [String: MixpanelType]? {
		let convertedParams: [String: MixpanelType] = self.reduce(into: [:]) { $0[$1.key.description] = $1.value.rawValue }
		return convertedParams
	}
}

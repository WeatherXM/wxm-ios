//
//  MockMainUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import DomainLayer

final class MockMainUseCase: MainUseCaseApi {
	nonisolated(unsafe) private var dictionary: [String: Any] = [:]
	nonisolated(unsafe) var lastAppVersionPrompt: String?
	nonisolated(unsafe) var termsAccepted: Bool = false
	nonisolated(unsafe) var showOnboarding: Bool = false

	var userLoggedInStateNotificationPublisher: NotificationCenter.Publisher {
		NotificationCenter.default.publisher(for: Notification.Name("MockMainUseCase.userLoggedInStateNotificationPublisher"))
	}

	func saveOrUpdateWeatherMetric(unitProtocol: UnitsProtocol) {
		dictionary[unitProtocol.key] = unitProtocol
	}
	
	func readOrCreateWeatherMetric(key: String) -> UnitsProtocol? {
		var value = dictionary[key] as? UnitsProtocol
		if let value {
			return value
		}

		value = UnitsObjectFactory().spawnDefault(from: key)
		return value
	}
	
	func saveValue<T>(key: String, value: T) {
		dictionary[key] = value
	}
	
	func getValue<T>(key: String) -> T? {
		dictionary[key] as? T
	}
	
	func shouldShowUpdatePrompt(for version: String, minimumVersion: String?, currentVersion: String?) -> Bool {
		true
	}
	
	func updateLastAppVersionPrompt(with version: String) {
		lastAppVersionPrompt = version
	}
	
	func shouldForceUpdate(minimumVersion: String?, currentVersion: String?) -> Bool {
		true
	}
	
	func setTermsOfUseAccepted() {
		termsAccepted = true
	}
	
	func areTermsOfUseAccepted() -> Bool {
		termsAccepted
	}

	func shouldShowOnboarding() -> Bool {
		showOnboarding
	}

	func markOnboardingAsShown() {
		showOnboarding = false
	}
}

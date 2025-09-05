//
//  MainUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Combine
import Toolkit

public protocol MainUseCaseApi: Sendable {
	var userLoggedInStateNotificationPublisher: NotificationCenter.Publisher { get }

	func saveOrUpdateWeatherMetric(unitProtocol: UnitsProtocol)
	func readOrCreateWeatherMetric(key: String) -> UnitsProtocol?
	func saveValue<T>(key: String, value: T)
	func getValue<T>(key: String) -> T?
	func shouldShowUpdatePrompt(for version: String, minimumVersion: String?, currentVersion: String?) -> Bool
	func updateLastAppVersionPrompt(with version: String)
	func shouldForceUpdate(minimumVersion: String?, currentVersion: String?) -> Bool
	func setTermsOfUseAccepted()
	func areTermsOfUseAccepted() -> Bool
	func shouldShowOnboarding() -> Bool
	func markOnboardingAsShown()
}

//
//  FirebaseManagerTypes.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 19/12/23.
//

import Foundation
import Combine
import UserNotifications

protocol FirbaseManagerImplementation {
	var latestReceivedNotificationPublisher: AnyPublisher<UNNotificationResponse?, Never>? { get }
	var notificationsAuthorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus?, Never>? { get }

	func launch()
	func getInstallationId() async -> String
	func setAnalyticsCollectionEnabled(_ enabled: Bool)
	func requestNotificationAuthorization() async throws
	func getAuthorizationStatus() async -> UNAuthorizationStatus
	func setApnsToken(_ token: Data)
}

protocol RemoteConfigManagerImplementation: AnyObject {
	var shouldUpdateCallback: VoidCallback? { get set }
	func getConfigValue<T>(type: T.Type,
						   key: RemoteConfigKey) -> T?
}

public enum RemoteConfigKey: String, CaseIterable {
	case iosTestIntegration = "ios_test_integration"
	case rewardsHideAnnotationThreshold = "rewards_hide_annotation_threshold"
	case iosAppChangelog = "ios_app_changelog"
	case iosAppLatestVersion = "ios_app_latest_version"
	case iosAppMinimumVersion = "ios_app_minimum_version"
	case featMainnet = "feat_mainnet"
	case featMainnetMessage = "feat_mainnet_message"

	private var defaultValue: NSObject {
		switch self {
			case .iosTestIntegration:
				return "-" as NSObject
			case .rewardsHideAnnotationThreshold:
				return NSNumber(integerLiteral: 100)
			case .iosAppChangelog:
				return "-" as NSObject
			case .iosAppLatestVersion:
				return "-" as NSObject
			case .iosAppMinimumVersion:
				return "-" as NSObject
			case .featMainnet:
				return NSNumber(booleanLiteral: false)
			case .featMainnetMessage:
				return "-" as NSObject
		}
	}

	internal static var defaults: [String: NSObject]? {
		var dict: [String: NSObject] = [:]
		RemoteConfigKey.allCases.forEach { key in
			dict += [key.rawValue: key.defaultValue]
		}

		return dict
	}
}

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
	var notificationsAuthStatusPublisher: AnyPublisher<UNAuthorizationStatus?, Never>? { get }
	var fcmTokenPublisher: AnyPublisher<String?, Never>? { get }

	func launch()
	func getInstallationId() async -> String
	func getFCMToken() -> String?
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
	case iosAppChangelog = "ios_app_changelog"
	case iosAppLatestVersion = "ios_app_latest_version"
	case iosAppMinimumVersion = "ios_app_minimum_version"
	case surveyId = "survey_id"
	case surveyTitle = "survey_title"
	case surveyMessage = "survey_message"
	case surveyActionLabel = "survey_action_label"
	case surveyUrl = "survey_url"
	case surveyShow = "survey_show"

	case infoBannerId = "info_banner_id"
	case infoBannerTitle = "info_banner_title"
	case infoBannerMessage = "info_banner_message"
	case infoBannerActionShow = "info_banner_action_show"
	case infoBannerActionLabel = "info_banner_action_label"
	case infoBannerActionUrl = "info_banner_action_url"
	case infoBannerShow = "info_banner_show"
	case infoBannerDismissable = "info_banner_dismissable"

	case announcementId = "announcement_id"
	case announcementTitle = "announcement_title"
	case announcementMessage = "announcement_message"
	case announcementActionLabel = "announcement_action_label"
	case announcementActionUrl = "announcement_action_url"
	case announcementActionShow = "announcement_action_show"
	case announcementShow = "announcement_show"
	case announcementDismissable = "announcement_dismissable"

	private var defaultValue: NSObject {
		switch self {
			case .iosTestIntegration:
				return "-" as NSObject
			case .iosAppChangelog:
				return "-" as NSObject
			case .iosAppLatestVersion:
				return "-" as NSObject
			case .iosAppMinimumVersion:
				return "-" as NSObject
			case .surveyId:
				return "-" as NSObject
			case .surveyTitle:
				return "-" as NSObject
			case .surveyMessage:
				return "-" as NSObject
			case .surveyActionLabel:
				return "-" as NSObject
			case .surveyUrl:
				return "-" as NSObject
			case .surveyShow:
				return false as NSObject
			case .infoBannerId:
				return "-" as NSObject
			case .infoBannerTitle:
				return "-" as NSObject
			case .infoBannerMessage:
				return "-" as NSObject
			case .infoBannerActionShow:
				return false as NSObject
			case .infoBannerActionLabel:
				return "-" as NSObject
			case .infoBannerActionUrl:
				return "-" as NSObject
			case .infoBannerShow:
				return false as NSObject
			case .infoBannerDismissable:
				return false as NSObject
			case .announcementId:
				return "-" as NSObject
			case .announcementTitle:
				return "-" as NSObject
			case .announcementMessage:
				return "-" as NSObject
			case .announcementActionLabel:
				return "-" as NSObject
			case .announcementActionUrl:
				return "-" as NSObject
			case .announcementActionShow:
				return false as NSObject
			case .announcementShow:
				return false as NSObject
			case .announcementDismissable:
				return false as NSObject
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

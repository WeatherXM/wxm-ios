//
//  StationNotificationsUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 9/7/25.
//

import Foundation

public enum StationNotificationsTypes: String {
	case activity
	case battery
	case firmwareUpdate
	case health
}

public protocol StationNotificationsUseCaseApi: Sendable {
	func areNotificationsEnabledForDevice(_ deviceId: String) -> Bool
	func setNotificationsForDevice(_ deviceId: String, enabled: Bool)
	func setNotificationEnabled(_ enabled: Bool, deviceId: String, for type: StationNotificationsTypes)
	func isNotificationEnabled(_ type: StationNotificationsTypes, deviceId: String) -> Bool
}

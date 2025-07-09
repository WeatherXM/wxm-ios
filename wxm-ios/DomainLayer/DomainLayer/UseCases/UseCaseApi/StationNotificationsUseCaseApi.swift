//
//  StationNotificationsUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 9/7/25.
//

import Foundation

public enum StationNotificationsTypes: CaseIterable {
	case activity
	case battery
	case firmwareUpdate
	case health
}

public protocol StationNotificationsUseCaseApi: Sendable {
	func setNotificationEnabled(_ enabled: Bool, for type: StationNotificationsTypes)
	func isNotificationEnabled(_ type: StationNotificationsTypes) -> Bool
}

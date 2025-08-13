//
//  StationAlert+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/7/25.
//

import Foundation
import DomainLayer
import Toolkit

extension StationNotificationsTypes {
	var notificationTitle: String {
		switch self {
			case .activity:
				LocalizableString.Error.notificationInactiveTitle.localized
			case .firmwareUpdate:
				LocalizableString.Error.notificationFirmwareTitle.localized
			case .battery:
				LocalizableString.Error.notificationBatteryTitle.localized
			case .health:
				LocalizableString.Error.notificationHealthTitle.localized
		}
	}

	func notificationDescription(for stationName: String) -> String {
		switch self {
			case .activity:
				LocalizableString.Error.notificationInactiveDescription(stationName).localized
			case .firmwareUpdate:
				LocalizableString.Error.notificationFirmwareDescription(stationName).localized
			case .battery:
				LocalizableString.Error.notificationBatteryDescription(stationName).localized
			case .health:
				LocalizableString.Error.notificationHealthDescription(stationName).localized
		}
	}

	var analyticsValue: ParameterValue {
		switch self {
			case .activity:
					.activity
			case .battery:
					.lowBatteryItem
			case .firmwareUpdate:
					.otaUpdate
			case .health:
					.stationHealth
		}
	}
}

//
//  StationAlert+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/7/25.
//

import Foundation
import DomainLayer
import Toolkit

extension StationAlert {
	var notificationTitle: String {
		switch self {
			case .inactive:
				LocalizableString.Error.notificationInactiveTitle.localized
			case .firmware:
				LocalizableString.Error.notificationFirmwareTitle.localized
			case .battery:
				LocalizableString.Error.notificationBatteryTitle.localized
			case .health:
				LocalizableString.Error.notificationHealthTitle.localized
		}
	}

	func notificationDescription(for stationName: String) -> String {
		switch self {
			case .inactive:
				LocalizableString.Error.notificationInactiveDescription(stationName).localized
			case .firmware:
				LocalizableString.Error.notificationFirmwareDescription(stationName).localized
			case .battery:
				LocalizableString.Error.notificationBatteryDescription(stationName).localized
			case .health:
				LocalizableString.Error.notificationHealthDescription(stationName).localized
		}
	}
}

extension StationNotificationsTypes {
	var analyticsValue: ParameterValue {
		switch self {
			case .activity:
					.activity
			case .battery:
					.lowBattery
			case .firmwareUpdate:
					.otaUpdate
			case .health:
					.stationHealth
		}
	}
}

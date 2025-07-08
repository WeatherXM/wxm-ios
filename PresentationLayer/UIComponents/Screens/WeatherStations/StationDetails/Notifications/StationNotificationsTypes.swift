//
//  StationNotificationsTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/7/25.
//

import Foundation

enum StationNotificationsTypes: CaseIterable, CustomStringConvertible {
	case activity
	case battery
	case firmwareUpdate
	case health

	var title: String {
		switch self {
			case .activity:
				LocalizableString.StationDetails.activity.localized
			case .battery:
				LocalizableString.StationDetails.battery.localized
			case .firmwareUpdate:
				LocalizableString.StationDetails.firmwareUpdate.localized
			case .health:
				LocalizableString.StationDetails.health.localized
		}
	}

	var description: String {
		switch self {
			case .activity:
				LocalizableString.StationDetails.activityDescription.localized
			case .battery:
				LocalizableString.StationDetails.batteryDescription.localized
			case .firmwareUpdate:
				LocalizableString.StationDetails.firmwareUpdateDescription.localized
			case .health:
				LocalizableString.StationDetails.healthDescription.localized
		}
	}
}

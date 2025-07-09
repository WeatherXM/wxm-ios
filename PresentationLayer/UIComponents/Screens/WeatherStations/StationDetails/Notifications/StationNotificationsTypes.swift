//
//  StationNotificationsTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/7/25.
//

import Foundation
import DomainLayer

extension StationNotificationsTypes: @retroactive CustomStringConvertible {
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

	public var description: String {
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

//
//  LocalizableString+RewardAnalytics.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import Foundation

extension LocalizableString {
	enum RewardAnalytics {
		case stationRewards
		case emptyStateTitle
		case emptyStateDescription
	}
}

extension LocalizableString.RewardAnalytics: WXMLocalizable {
	var localized: String {
		let localized = NSLocalizedString(key, comment: "")
		return localized
	}

	var key: String {
		switch self {
			case .stationRewards:
				return "reward_analytics_station_rewards"
			case .emptyStateTitle:
				return "reward_analytics_empty_state_title"
			case .emptyStateDescription:
				return "reward_analytics_empty_state_description"
		}
	}
}
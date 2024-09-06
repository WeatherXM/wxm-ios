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
		case totalEarnedFor(Int)
		case lastRun
		case totalEarned
		case rewardsByStation
		case details(String)
		case betaRewards
		case totalTokensEarnedSoFar
	}
}

extension LocalizableString.RewardAnalytics: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		switch self {
			case .totalEarnedFor(let count):
				localized = String(format: localized, count)
			case .details(let value):
				localized = String(format: localized, value)
			default:
				break
		}

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
			case .totalEarnedFor(let count):
				return count > 1 ? "reward_analytics_total_earned_for_plural" : "reward_analytics_total_earned_for"
			case .lastRun:
				return "reward_analytics_last_run"
			case .totalEarned:
				return "reward_analytics_total_earned"
			case .rewardsByStation:
				return "reward_analytics_rewards_by_station"
			case .details:
				return "reward_analytics_details"
			case .betaRewards:
				return "reward_analytics_beta_rewards"
			case .totalTokensEarnedSoFar:
				return "reward_analytics_total_tokens_earned_so_far"
		}
	}
}

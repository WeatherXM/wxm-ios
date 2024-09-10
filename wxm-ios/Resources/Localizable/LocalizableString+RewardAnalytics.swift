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
		case rewardsBreakdown
		case rewardsByStation
		case details(String)
		case betaRewards
		case totalTokensEarnedSoFar
		case weekAbbrevation
		case monthAbbrevation
		case yearAbbrevation
		case earnedByThisStation
		case otherBoost
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
			case .rewardsBreakdown:
				return "reward_analytics_rewards_breakdown"
			case .rewardsByStation:
				return "reward_analytics_rewards_by_station"
			case .details:
				return "reward_analytics_details"
			case .betaRewards:
				return "reward_analytics_beta_rewards"
			case .totalTokensEarnedSoFar:
				return "reward_analytics_total_tokens_earned_so_far"
			case .weekAbbrevation:
				return "reward_analytics_week_abbrevation"
			case .monthAbbrevation:
				return "reward_analytics_month_abbrevation"
			case .yearAbbrevation:
				return "reward_analytics_year_abbrevation"
			case .earnedByThisStation:
				return "reward_analytics_earned_by_this_station"
			case .otherBoost:
				return "reward_analytics_other_boost"
		}
	}
}

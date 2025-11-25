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
		case beta
		case rollouts
		case rolloutsRewards
		case compensation
		case compensationRewards
		case cellBounty
		case cellBountyRewards
		case totalTokensEarnedSoFar
		case weekAbbrevation
		case monthAbbrevation
		case yearAbbrevation
		case earnedByThisStation
		case otherBoost
		case otherRewards
		case base
		case baseRewards
		case tapToRetry
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
			case .beta:
				return "reward_analytics_beta"
			case .rollouts:
				return "reward_analytics_rollouts"
			case .rolloutsRewards:
				return "reward_analytics_rollouts_rewards"
			case .compensation:
				return "reward_analytics_compensation"
			case .compensationRewards:
				return "reward_analytics_compensation_rewards"
			case .cellBounty:
				return "reward_analytics_cell_bounty"
			case .cellBountyRewards:
				return "reward_analytics_cell_bounty_rewards"
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
			case .otherRewards:
				return "reward_analytics_other_rewards"
			case .base:
				return "reward_analytics_base"
			case .baseRewards:
				return "reward_analytics_base_rewards"
			case .tapToRetry:
				return "reward_analytics_tap_to_retry"
		}
	}
}

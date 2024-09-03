//
//  Localizable+Boosts.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import Foundation

extension LocalizableString {
	enum Boosts {
		case boostTokensEarned(String)
		case dailyBoostScore
		case lostTokens(String)
		case lostTokensBecauseOfQod(String)
		case gotAllBetaRewards
		case boostDetails
		case boostDetailsDescription(String, String)
		case rewardableStationHours
		case dailyTokensToBeRewarded
		case totalTokensToBeRewarded
		case boostPeriod
	}
}

extension LocalizableString.Boosts: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		switch self {
			case .boostTokensEarned(let text),
				 .lostTokens(let text),
				 .lostTokensBecauseOfQod(let text):
				localized = String(format: localized, text)
			case .boostDetailsDescription(let from, let to):
				localized = String(format: localized, arguments: [from, to].compactMap { $0 })
			default: break
		}

		return localized

	}

	var key: String {
		switch self {
			case .boostTokensEarned:
				"boosts_tokens_earned_format"
			case .dailyBoostScore:
				"boosts_daily_boost_score"
			case .lostTokens:
				"boosts_lost_tokens_format"
			case .lostTokensBecauseOfQod:
				"boosts_lost_tokens_because_of_qod_format"
			case .gotAllBetaRewards:
				"boosts_got_all_beta_rewards"
			case .boostDetails:
				"boosts_boost_details"
			case .boostDetailsDescription:
				"boosts_boost_details_decription_format"
			case .rewardableStationHours:
				"boosts_rewardable_station_hours"
			case .dailyTokensToBeRewarded:
				"boosts_daily_tokens_to_be_rewarded"
			case .totalTokensToBeRewarded:
				"boosts_total_tokens_to_be_rewarded"
			case .boostPeriod:
				"boosts_boost_period"
		}
	}
}

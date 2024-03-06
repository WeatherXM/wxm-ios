//
//  LocalizableString+StationDetails.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/9/23.
//

import Foundation

extension LocalizableString {
	enum StationDetails {
		case observations
		case forecast
		case rewards
		case viewHistoricalData
		case rewardsInfoText
		case observationsFollowCtaText
		case observationsLoggedOutCtaText
		case detailedRewardsButtonTitle
		case sevenDaysAbbreviation
		case thirtyDaysAbbreviation

		case noWeatherData
		case noWeatherDataDescription
		case noWeatherDataDescriptionForDate

		case dailyRewardTitle
		case dailyRewardEarnings(String)
		case baseReward
		case boosts
		case noActiveBoosts
		case viewRewardDetailsButtonTitle
		case viewTimelineButtonTitle
		case ownedStationRewardInfoMessage
		case stationRewardInfoMessage(Int)
		case ownedStationRewardWarningMessage
		case stationRewardWarningMessage(Int)
		case ownedStationRewardErrorMessage
		case stationRewardErrorMessage(Int)
		case weeklyStreak
		case noRewardsTitle
		case noRewardsDescription
		case mainnetTitle
		case rewardsTitle
		case rewardsLatestTab
		case rewardsSevenDaysTab
		case rewardsThirtyDaysTab
		case gotRewards(Int)
		case lostRewards(Int)
		case rewardsErrorsTitle
		case rewardsErrorDescription(String)
		case rewardsErrorButtonTitle
		case ownedRewardsErrorButtonTitle
		case rewardsScore
		case rewardsMax
		case rewardsTimelineCaption(String)
		case proTipTitle
		case proTipDescription
	}
}

extension LocalizableString.StationDetails: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(self.key, comment: "")
		switch self {
			case .gotRewards(let value), 
					.lostRewards(let value),
					.stationRewardInfoMessage(let value),
					.stationRewardWarningMessage(let value),
					.stationRewardErrorMessage(let value):
				localized = String(format: localized, value)
			case .rewardsTimelineCaption(let text), 
					.rewardsErrorDescription(let text), 
					.dailyRewardEarnings(let text):
				localized = String(format: localized, text)
			default:
				break
		}

		return localized
	}

	var key: String {
		switch self {
			case .observations:
				return "station_details_observations"
			case .forecast:
				return "station_details_forecast"
			case .rewards:
				return "station_details_rewards"
			case .viewHistoricalData:
				return "station_details_view_historical_data"
			case .rewardsInfoText:
				return "station_details_rewards_info_text"
			case .observationsFollowCtaText:
				return "station_details_observations_follow_cta_text"
			case .observationsLoggedOutCtaText:
				return "station_details_observations_logged_out_cta_text"
			case .detailedRewardsButtonTitle:
				return "station_details_detailed_rewards_button_title"
			case .sevenDaysAbbreviation:
				return "station_details_seven_days_abbreviation"
			case .thirtyDaysAbbreviation:
				return "station_details_thirty_days_abbreviation"
			case .noWeatherData:
				return "station_details_no_weather_data"
			case .noWeatherDataDescription:
				return "station_details_no_weather_data_description"
			case .noWeatherDataDescriptionForDate:
				return "station_details_no_weather_data_description_for_date"
			case .dailyRewardTitle:
				return "station_details_daily_reward_title"
			case .dailyRewardEarnings:
				return "station_details_daily_reward_earnings_format"
			case .baseReward:
				return "station_details_base_reward"
			case .boosts:
				return "station_details_boosts"
			case .noActiveBoosts:
				return "station_details_no_active_boosts"
			case .viewRewardDetailsButtonTitle:
				return "station_details_view_reward_details_button_title"
			case .viewTimelineButtonTitle:
				return "station_details_view_timeline_button_title"
			case .ownedStationRewardInfoMessage:
				return "station_details_owned_reward_info_message"
			case .ownedStationRewardErrorMessage:
				return "station_details_owned_reward_error_message"
			case .stationRewardInfoMessage(let count):
				guard count > 1 else {
					return "station_details_reward_info_message_format"
				}
				return "station_details_reward_info_message_plural_format"
			case .stationRewardWarningMessage(let count):
				guard count > 1 else {
					return "station_details_reward_warning_message_format"
				}
				return "station_details_reward_warning_message_plural_format"
			case .stationRewardErrorMessage(let count):
				guard count > 1 else {
					return "station_details_reward_error_message_format"
				}
				return "station_details_reward_error_message_plural_format"
			case .weeklyStreak:
				return "station_details_weekly_streak"
			case .noRewardsTitle:
				return "station_details_no_rewards_title"
			case .noRewardsDescription:
				return "station_details_no_rewards_description"
			case .mainnetTitle:
				return "station_details_mainnet_banner_title"
			case .ownedStationRewardWarningMessage:
				return "station_details_owned_reward_warning_message"
			case .rewardsTitle:
				return "station_details_rewards_title"
			case .gotRewards:
				return "station_details_got_rewards_format"
			case .lostRewards:
				return "station_details_lost_rewards_format"
			case .rewardsLatestTab:
				return "station_details_rewards_latest"
			case .rewardsSevenDaysTab:
				return "station_details_rewards_seven_days"
			case .rewardsThirtyDaysTab:
				return "station_details_rewards_thirty_days"
			case .rewardsErrorsTitle:
				return "station_details_rewards_error_title"
			case .rewardsErrorDescription:
				return "station_details_rewards_error_description_format"
			case .rewardsErrorButtonTitle:
				return "station_details_rewards_error_button_title"
			case .ownedRewardsErrorButtonTitle:
				return "station_details_owned_rewards_error_button_title"
			case .rewardsScore:
				return "station_details_rewards_score"
			case .rewardsMax:
				return "station_details_rewards_max"
			case .rewardsTimelineCaption:
				return "station_details_rewards_timeline_caption_format"
			case .proTipTitle:
				return "station_details_rewards_pro_tip_title"
			case .proTipDescription:
				return "station_details_rewards_pro_tip_description"
		}
	}
}

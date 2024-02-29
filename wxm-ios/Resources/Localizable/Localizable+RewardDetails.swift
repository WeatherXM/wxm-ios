//
//  Localizable+RewardDetails.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/10/23.
//

import Foundation

extension LocalizableString {
	enum RewardDetails {
		case title
		case dailyReward
		case issues
		case earningsFor(String)
		case viewAllIssues
		case earnedRewardDescription(String, String)
		case dataQuality
		case locationQuality
		case cellPosition
		case dataQualitySolidMessage(Int)
		case dataQualityAlmostPerfectMessage(Int)
		case dataQualityGreatMessage(Int)
		case dataQualityPublicGreatMessage(Int)
		case dataQualityOkMessage(Int)
		case dataQualityPublicOkMessage(Int)
		case dataQualityAverageMessage(Int)
		case dataQualityPublicAverageMessage(Int)
		case dataQualityLowMessage(Int)
		case dataQualityPublicLowMessage(Int)
		case dataQualityVeryLowMessage(Int)
		case dataQualityPublicVeryLowMessage(Int)
		case dataQualityLostMessage
		case dataQualityNoInfoMessage
		case problemsTitle
		case problemsDescription(String)
		case zeroLostProblemsDescription
		case problemButtonTitle
		case upgradeFirmwareButtonTitle
		case noWalletProblemButtonTitle
		case viewTransaction
		case readMore
		case rewardIssues
		case reportFor(String)
		case editLocation
		case rewardScoreInfoTitle
		case rewardScoreInfoDescription(String)
		case maxRewardsInfoTitle
		case maxRewardsInfoDescription(String)
		case timelineInfoTitle
		case timelineInfoDescription(String?, String)
		case contactSupportButtonTitle
	}
}

extension LocalizableString.RewardDetails: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		switch self {
			case .dataQualitySolidMessage(let count),
					.dataQualityAlmostPerfectMessage(let count),
					.dataQualityGreatMessage(let count),
					.dataQualityPublicGreatMessage(let count),
					.dataQualityOkMessage(let count),
					.dataQualityPublicOkMessage(let count),
					.dataQualityAverageMessage(let count),
					.dataQualityPublicAverageMessage(let count),
					.dataQualityLowMessage(let count),
					.dataQualityPublicLowMessage(let count),
					.dataQualityVeryLowMessage(let count),
					.dataQualityPublicVeryLowMessage(let count):
				localized = String(format: localized, count)
			case .problemsDescription(let text),
					.rewardScoreInfoDescription(let text),
					.maxRewardsInfoDescription(let text),
					.reportFor(let text),
					.earningsFor(let text):
				localized = String(format: localized, text)
			case .earnedRewardDescription(let earned, let dailyMax):
				localized = String(format: localized, arguments: [earned, dailyMax].compactMap { $0 })
			case .timelineInfoDescription(let timezoneOffset, let url):
				localized = String(format: localized, arguments: [timezoneOffset, url].compactMap { $0 })
			default: break
		}

		return localized
	}

	var key: String {
		switch self {
			case .title:
				return "reward_details_title"
			case .dailyReward:
				return "reward_details_daily_reward"
			case .issues:
				return "reward_details_issues"
			case .earningsFor:
				return "reward_details_earnings_for_format"
			case .problemsTitle:
				return "reward_problems_title"
			case .viewAllIssues:
				return "reward_details_view_all_issues"
			case .earnedRewardDescription:
				return "reward_details_earned_reward_description_format"
			case .dataQuality:
				return "reward_details_data_quality"
			case .locationQuality:
				return "reward_details_location_quality"
			case .cellPosition:
				return "reward_details_cell_position"
			case .dataQualitySolidMessage:
				return "reward_details_data_quality_solid_message"
			case .dataQualityAlmostPerfectMessage:
				return "reward_details_data_quality_perfect_message"
			case .dataQualityGreatMessage:
				return "reward_details_data_quality_great_message"
			case .dataQualityPublicGreatMessage:
				return "reward_details_data_quality_public_great_message"
			case .dataQualityOkMessage:
				return "reward_details_data_quality_ok_message"
			case .dataQualityPublicOkMessage:
				return "reward_details_data_quality_public_ok_message"
			case .dataQualityAverageMessage:
				return "reward_details_data_quality_average_message"
			case .dataQualityPublicAverageMessage:
				return "reward_details_data_quality_public_average_message"
			case .dataQualityLowMessage:
				return "reward_details_data_quality_low_message"
			case .dataQualityPublicLowMessage:
				return "reward_details_data_quality_public_low_message"
			case .dataQualityVeryLowMessage:
				return "reward_details_data_quality_very_low_message"
			case .dataQualityPublicVeryLowMessage:
				return "reward_details_data_quality_public_very_low_message"
			case .dataQualityLostMessage:
				return "reward_details_data_quality_lost_message"
			case .dataQualityNoInfoMessage:
				return "reward_details_data_quality_no_info_message"

			case .problemsDescription:
				return "reward_problems_description_format"
			case .zeroLostProblemsDescription:
				return "reward_problems_zero_lost_description"
			case .problemButtonTitle:
				return "reward_problem_button_title"
			case .upgradeFirmwareButtonTitle:
				return "reward_problem_upgrade_firmware_button_title"
			case .noWalletProblemButtonTitle:
				return "reward_problem_no_wallet_button_title"
			case .viewTransaction:
				return "reward_details_view_transaction"
			case .readMore:
				return "reward_details_read_more"
			case .rewardIssues:
				return "reward_details_reward_issues"
			case .reportFor:
				return "reward_details_report_for_format"
			case .editLocation:
				return "reward_details_edit_location"
			case .rewardScoreInfoTitle:
				return "reward_details_reward_score_info_title"
			case .rewardScoreInfoDescription:
				return "reward_details_reward_score_info_description_format"
			case .maxRewardsInfoTitle:
				return "reward_details_max_rewards_info_title"
			case .maxRewardsInfoDescription:
				return "reward_details_max_rewards_info_description_format"
			case .timelineInfoTitle:
				return "reward_details_timeline_info_title"
			case .timelineInfoDescription(let offsetString, _):
				if offsetString == nil {
					return "reward_details_timeline_info_missing_tz_description_format"
				}
				return "reward_details_timeline_info_description_format"
			case .contactSupportButtonTitle:
				return "reward_details_contact_support_button_title"
		}
	}
}

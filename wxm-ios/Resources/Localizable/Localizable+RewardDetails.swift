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
			case .problemsDescription(let text),
					.rewardScoreInfoDescription(let text),
					.maxRewardsInfoDescription(let text),
					.reportFor(let text),
					.earningsFor(let text):
				localized = String(format: localized, text)
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

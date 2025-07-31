//
//  LocalizableString+Profile.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/11/23.
//

import Foundation

extension LocalizableString {
	enum Profile {
		case title
		case loginToSee
		case allocatedRewards
		case noRewardsDescription
		case noRewardsWarningTitle
		case noRewardsWarningDescription
		case noRewardsWarningButtonTitle
		case claimFromWebDescription(String)
		case claimFromWebAlertMessage(String)
		case myWallet
		case noWalletAddressDescription
		case noWalletAddressErrorTitle
		case noWalletAddressErrorDescription
		case prefsSettings
		case prefsSettingsDescription
		case claimButtonTitle
		case totalEarned
		case totalClaimed
		case claimFlowTitle
		case totalClaimedInfoTitle
		case totalClaimedInfoDescription
		case totalEarnedInfoTitle
		case totalEarnedInfoDescription
	}
}

extension LocalizableString.Profile: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(self.key, comment: "")
		switch self {
			case .claimFromWebDescription(let text), .claimFromWebAlertMessage(let text):
				localized = String(format: localized, text)
			default:
				break
		}

		return localized
	}

	var key: String {
		switch self {
			case .title:
				return "profile_title"
			case .loginToSee:
				return "profile_login_to_see"
			case .allocatedRewards:
				return "profile_allocated_rewards"
			case .noRewardsDescription:
				return "profile_no_rewards_description"
			case .noRewardsWarningTitle:
				return "profile_no_rewards_warning_title"
			case .noRewardsWarningDescription:
				return "profile_no_rewards_warning_description"
			case .noRewardsWarningButtonTitle:
				return "profile_no_rewards_warning_button_title"
			case .claimFromWebDescription:
				return "profile_claim_from_web_description"
			case .claimFromWebAlertMessage:
				return "profile_claim_from_web_alert_message"
			case .myWallet:
				return "profile_my_wallet"
			case .noWalletAddressDescription:
				return "profile_no_wallet_address_description"
			case .noWalletAddressErrorTitle:
				return "profile_no_wallet_address_error_title"
			case .noWalletAddressErrorDescription:
				return "profile_no_wallet_address_error_description"
			case .prefsSettings:
				return "profile_prefs_settings"
			case .prefsSettingsDescription:
				return "profile_prefs_settings_description"
			case .claimButtonTitle:
				return "profile_claim_button_title"
			case .totalEarned:
				return "profile_total_earned"
			case .totalClaimed:
				return "profile_total_claimed"
			case .claimFlowTitle:
				return "profile_claim_flow_title"
			case .totalClaimedInfoTitle:
				return "profile_total_claimed_info_title"
			case .totalClaimedInfoDescription:
				return "profile_total_claimed_info_description"
			case .totalEarnedInfoTitle:
				return "profile_total_earned_info_title"
			case .totalEarnedInfoDescription:
				return "profile_total_earned_info_description"
		}
	}
}

//
//  BoostCode+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/9/24.
//

import Foundation
import DomainLayer

extension BoostCode {
	var displayName: String {
		switch self {
			case .betaReward:
				return LocalizableString.RewardAnalytics.beta.localized
			case .trov2:
				return LocalizableString.RewardAnalytics.rollouts.localized
			case .correction:
				return LocalizableString.RewardAnalytics.compensation.localized
			case .cellBounty:
				return LocalizableString.RewardAnalytics.cellBounties.localized
			case .unknown:
				return LocalizableString.RewardAnalytics.otherBoost.localized
		}
	}

	var primaryColor: ColorEnum {
		switch self {
			case .betaReward:
				return .betaRewardsPrimary
			case .trov2:
				return .troRewardsPrimary
			case .correction:
				return .correctionRewardsPrimary
			case .cellBounty:
				return .cellBountiesPrimary
			case .unknown:
				return .otherRewardPrimary
		}
	}

	var fillColor: ColorEnum {
		switch self {
			case .betaReward:
				return .betaRewardsFill
			case .trov2:
				return .troRewardsFill
			case .correction:
				return .correctionRewardsFill
			case .cellBounty:
				return .cellBountiesFill
			case .unknown:
				return .otherRewardFill
		}
	}

	var chartColor: ColorEnum {
		switch self {
			case .betaReward:
				return .betaRewardsPrimary
			case .trov2:
				return .troRewardsPrimary
			case .correction:
				return .correctionRewardsFill
			case .cellBounty:
				return .cellBountiesFill
			case .unknown:
				return .otherRewardChart
		}
	}

	var legendTitle: String {
		switch self {
			case .betaReward:
				return LocalizableString.RewardAnalytics.betaRewards.localized
			case .trov2:
				return LocalizableString.RewardAnalytics.rolloutsRewards.localized
			case .correction:
				return LocalizableString.RewardAnalytics.compensationRewards.localized
			case .cellBounty:
				return LocalizableString.RewardAnalytics.cellBountiesRewards.localized
			case .unknown:
				return LocalizableString.RewardAnalytics.otherRewards.localized
		}
	}
}

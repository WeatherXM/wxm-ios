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
				return LocalizableString.RewardAnalytics.betaRewards.localized
			case .unknown(let value):
				return value
		}
	}

	var primaryColor: ColorEnum {
		switch self {
			case .betaReward:
				return .betaRewardsPrimary
			case .unknown:
				return .wxmPrimary
		}
	}

	var fillColor: ColorEnum {
		switch self {
			case .betaReward:
				return .betaRewardsFill
			case .unknown:
				return .remoteImagePlaceholder
		}
	}
}

//
//  NetworkDeviceRewardsResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/9/24.
//

import Foundation
import DomainLayer

extension NetworkDeviceRewardsResponse.RewardItem {
	var chartColor: ColorEnum? {
		guard let type else {
			return nil
		}

		switch type {
			case .base:
				return .chartPrimary
			case .boost:
				return code?.chartColor
		}
	}

	var displayName: String? {
		guard let type else {
			return nil
		}

		switch type {
			case .base:
				return LocalizableString.RewardAnalytics.base.localized
			case .boost:
				return code?.displayName
		}
	}

	var legendTitle: String? {
		guard let type else {
			return nil
		}

		switch type {
			case .base:
				return LocalizableString.RewardAnalytics.baseRewards.localized
			case .boost:
				return code?.legendTitle
		}
	}
}

extension DeviceRewardsMode: CustomStringConvertible {
	public var description: String {
		switch self {
			case .week:
				LocalizableString.RewardAnalytics.weekAbbrevation.localized
			case .month:
				LocalizableString.RewardAnalytics.monthAbbrevation.localized
			case .year:
				LocalizableString.RewardAnalytics.yearAbbrevation.localized
		}
	}
}

extension NetworkDeviceRewardsResponse.Details {
	var boostStartDateString: String {
		boostPeriodStart?.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone).capitalizedSentence ?? ""
	}

	var boostStopDateString: String {
		boostPeriodEnd?.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone).capitalizedSentence ?? ""
	}
}

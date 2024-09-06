//
//  NetworkDeviceRewardsResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/9/24.
//

import Foundation
import DomainLayer

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

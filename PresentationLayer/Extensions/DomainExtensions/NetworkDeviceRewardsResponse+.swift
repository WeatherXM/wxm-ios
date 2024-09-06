//
//  NetworkDeviceRewardsResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/9/24.
//

import Foundation
import DomainLayer

extension NetworkDeviceRewardsResponse.Details {
	var boostStartDateString: String {
		boostPeriodStart?.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone).capitalizedSentence ?? ""
	}

	var boostStopDateString: String {
		boostPeriodEnd?.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone).capitalizedSentence ?? ""
	}
}

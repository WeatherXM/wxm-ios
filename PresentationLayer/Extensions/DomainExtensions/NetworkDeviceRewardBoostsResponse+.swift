//
//  NetworkDeviceRewardBoostsResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import DomainLayer

extension NetworkDeviceRewardBoostsResponse.Details {
	var boostStartDateString: String {
		boostStartDate?.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone).capitalized ?? ""
	}

	var boostStopDateString: String {
		boostStopDate?.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone).capitalized ?? ""
	}

	var participationStartDateString: String {
		participationStartDate?.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone).capitalized ?? ""
	}

	var participationStopDateString: String {
		participationStopDate?.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone).capitalized ?? ""
	}
}

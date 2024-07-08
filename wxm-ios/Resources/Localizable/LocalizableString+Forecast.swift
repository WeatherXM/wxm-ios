//
//  LocalizableString+Forecast.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 12/4/24.
//

import Foundation

extension LocalizableString {
	enum Forecast {
		case nextSevenDays
		case nextTwentyFourHours
		case dailyConditions
		case hourlyForecast
	}
}

extension LocalizableString.Forecast: WXMLocalizable {
	var localized: String {
		let localized = NSLocalizedString(key, comment: "")
		return localized
	}

	var key: String {
		switch self {
			case .nextSevenDays:
				return "forecast_next_seven_days"
			case .nextTwentyFourHours:
				return "forecast_next_twenty_four_hours"
			case .dailyConditions:
				return "forecast_daily_conditions"
			case .hourlyForecast:
				return "forecast_hourly_forecast"
		}
	}
}

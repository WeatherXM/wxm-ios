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
		case temperatureBarsTitle
		case weeklyRangeBar
		case weeklyRangeDescription
		case dailyRangeBar
		case dailyRangeDescription
		case joinTheNetwork
		case joinTheNetworkDescription
		case shopNow
		case hyperLocal
		case smarterSharper
		case hyperLocalCardDescription
		case seeThePlans
		case freeSubscriptionText
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
			case .temperatureBarsTitle:
				return "forecast_temperature_bars_title"
			case .weeklyRangeBar:
				return "forecast_weekly_range_bar"
			case .weeklyRangeDescription:
				return "forecast_weekly_range_description"
			case .dailyRangeBar:
				return "forecast_daily_range_bar"
			case .dailyRangeDescription:
				return "forecast_daily_range_description"
			case .joinTheNetwork:
				return "forecast_join_the_network"
			case .joinTheNetworkDescription:
				return "forecast_join_the_network_description"
			case .shopNow:
				return "forecast_shop_now"
			case .hyperLocal:
				return "forecast_hyper_local"
			case .smarterSharper:
				return "forecast_smarter_sharper"
			case .hyperLocalCardDescription:
				return "forecast_hyper_local_card_description"
			case .seeThePlans:
				return "forecast_see_the_plans"
			case .freeSubscriptionText:
				return "forecast_free_subscription_text"
		}
	}
}

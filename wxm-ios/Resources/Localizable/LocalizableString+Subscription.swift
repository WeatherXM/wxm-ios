//
//  LocalizableString+Subscription.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/11/25.
//

import Foundation

extension LocalizableString {
	enum Subscriptions {
		case currentPlan
		case standard
		case standardDescription
		case premium
		case active
		case premiumFeatures
		case mosaicForecast
		case mosaicForecastDescription
		case hourlyForecast
		case hourlyForecastDescription
		case getPremium
	}
}

extension LocalizableString.Subscriptions: WXMLocalizable {
	var localized: String {
		let localized = NSLocalizedString(key, comment: "")
		return localized
	}

	var key: String {
		switch self {
			case .currentPlan:
				"subscriptions_current_plan"
			case .standard:
				"subscriptions_standard"
			case .standardDescription:
				"subscriptions_standard_description"
			case .premium:
				"subscriptions_premium"
			case .active:
				"subscriptions_active"
			case .premiumFeatures:
				"subscriptions_premium_features"
			case .mosaicForecast:
				"subscriptions_mosaic_forecast"
			case .mosaicForecastDescription:
				"subscriptions_mosaic_forecast_description"
			case .hourlyForecast:
				"subscriptions_hourly_forecast"
			case .hourlyForecastDescription:
				"subscriptions_hourly_forecast_description"
			case .getPremium:
				"subscriptions_get_premium"
		}
	}
}

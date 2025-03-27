//
//  LocalizableString+Promotional.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 21/3/25.
//

import Foundation

extension LocalizableString {
	enum Promotional {
		case wxmPro
		case proDescription
		case forecastAccuracy
		case hyperlocalWeaterForecasts
		case historicalData
		case cellForecast
		case accessApi
		case andMore
		case choosePlan
		case learnMore
		case getPro
		case wantMoreAccurateForecast
		case takeYourWeatherInsights
		case getHyperlocalForecasts
		case unlockFullWeather
		case fineTuneForecast
	}
}

extension LocalizableString.Promotional: WXMLocalizable {
	var localized: String {
		let localized = NSLocalizedString(key, comment: "")
		return localized
	}

	var key: String {
		switch self {
			case .wxmPro:
				"promotional_wxm_pro"
			case .proDescription:
				"promotional_pro_description"
			case .forecastAccuracy:
				"promotional_forecast_accuracy"
			case .hyperlocalWeaterForecasts:
				"promotional_hyperlocal_weather_forecasts"
			case .historicalData:
				"promotional_historical_data"
			case .cellForecast:
				"promotional_cell_forecast"
			case .accessApi:
				"promotional_access_api"
			case .andMore:
				"promotional_and_more"
			case .choosePlan:
				"promotional_choose_plan"
			case .learnMore:
				"promotional_learn_more"
			case .getPro:
				"promotional_get_pro"
			case .wantMoreAccurateForecast:
				"promotional_want_more_accurate_forecast"
			case .takeYourWeatherInsights:
				"promotional_take_your_weather_insights"
			case .getHyperlocalForecasts:
				"promotional_get_hyperlocal_forecasts"
			case .unlockFullWeather:
				"promotional_unlock_full_weather"
			case .fineTuneForecast:
				"promotional_fine_tune_forecast"
		}
	}
}

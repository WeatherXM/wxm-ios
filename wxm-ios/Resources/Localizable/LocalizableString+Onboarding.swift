//
//  LocalizableString+Onboarding.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/25.
//

import Foundation

extension LocalizableString {
	enum Onboarding {
		case title
		case signUpButtonTitle
		case exploreTheAppButtonTitle
		case forecastForEveryCorner
		case liveTransparentNetwork
		case contributeAndEarn
		case communityPowered
		case localWeatherData
	}
}

extension LocalizableString.Onboarding: WXMLocalizable {
	var localized: String {
		let localized = NSLocalizedString(key, comment: "")
		return localized
	}

	var key: String {
		switch self {
			case .title:
				"onboarding_title"
			case .signUpButtonTitle:
				"onboarding_sign_up_button_title"
			case .exploreTheAppButtonTitle:
				"onboarding_explore_the_app_button_title"
			case .forecastForEveryCorner:
				"onboarding_forecast_for_every_corner"
			case .liveTransparentNetwork:
				"onboarding_live_transparent_network"
			case .contributeAndEarn:
				"onboarding_contribute_and_earn"
			case .communityPowered:
				"onboarding_community_powered"
			case .localWeatherData:
				"onboarding_local_weather_data"
		}
	}
}

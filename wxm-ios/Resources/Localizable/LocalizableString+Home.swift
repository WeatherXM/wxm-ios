//
//  LocalizableString+Home.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/9/23.
//

import Foundation

extension LocalizableString {
    enum Home {
        case totalWeatherStationsEmptyTitle
        case totalWeatherStationsEmptyDescription
        case totalWeatherStationsEmptyButtonTitle
        case ownedWeatherStationsEmptyTitle
        case ownedWeatherStationsEmptyDescription
        case followingWeatherStationsEmptyTitle
        case followingWeatherStationsEmptyDescription
        case followingWeatherStationsEmptyButtonTitle
		case noRewardsYet
		case dataQuality(Int)
    }
}

extension LocalizableString.Home: WXMLocalizable {
    var localized: String {
		var localized = NSLocalizedString(self.key, comment: "")
		switch self {
			case .dataQuality(let num):
				localized = String(format: localized, num)
			default:
				break
		}

		return localized

    }

    var key: String {
        switch self {
            case .totalWeatherStationsEmptyTitle:
                return "home_total_weather_stations_empty_title"
            case .totalWeatherStationsEmptyDescription:
                return "home_total_weather_stations_empty_description"
            case .totalWeatherStationsEmptyButtonTitle:
                return "home_total_weather_stations_empty_button_title"
            case .ownedWeatherStationsEmptyTitle:
                return "home_owned_weather_stations_empty_title"
            case .ownedWeatherStationsEmptyDescription:
                return "home_owned_weather_stations_empty_description"
            case .followingWeatherStationsEmptyTitle:
                return "home_following_weather_stations_empty_title"
            case .followingWeatherStationsEmptyDescription:
                return "home_following_weather_stations_empty_description"
            case .followingWeatherStationsEmptyButtonTitle:
                return "home_following_weather_stations_empty_button_title"
			case .noRewardsYet:
				return "home_no_rewards_yet"
			case .dataQuality:
				return "home_data_quality"
        }
    }
}

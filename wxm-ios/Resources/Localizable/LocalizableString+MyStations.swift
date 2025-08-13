//
//  LocalizableString+MyStations.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/9/23.
//

import Foundation

extension LocalizableString {
	enum MyStations {
		case totalWeatherStationsEmptyTitle
		case totalWeatherStationsEmptyDescription
		case totalWeatherStationsEmptyButtonTitle
		case ownedWeatherStationsEmptyTitle
		case ownedWeatherStationsEmptyDescription
		case followingWeatherStationsEmptyTitle
		case followingWeatherStationsEmptyDescription
		case followingWeatherStationsEmptyButtonTitle
		case noRewardsYet
		case joinTheNetwork
		case ownDeployEarn
		case ownDeployEarnWXM
		case buyStation
		case followAStationInExplorer
		case claimYourStationhere
		case dataQuality(Int)
	}
}

extension LocalizableString.MyStations: WXMLocalizable {
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
				return "my_stations_total_weather_stations_empty_title"
			case .totalWeatherStationsEmptyDescription:
				return "my_stations_total_weather_stations_empty_description"
			case .totalWeatherStationsEmptyButtonTitle:
				return "my_stations_total_weather_stations_empty_button_title"
			case .ownedWeatherStationsEmptyTitle:
				return "my_stations_owned_weather_stations_empty_title"
			case .ownedWeatherStationsEmptyDescription:
				return "my_stations_owned_weather_stations_empty_description"
			case .followingWeatherStationsEmptyTitle:
				return "my_stations_following_weather_stations_empty_title"
			case .followingWeatherStationsEmptyDescription:
				return "my_stations_following_weather_stations_empty_description"
			case .followingWeatherStationsEmptyButtonTitle:
				return "my_stations_following_weather_stations_empty_button_title"
			case .noRewardsYet:
				return "my_stations_no_rewards_yet"
			case .dataQuality:
				return "my_stations_data_quality"
			case .joinTheNetwork:
				return "my_stations_join_the_network"
			case .ownDeployEarn:
				return "my_stations_own_deploy_earn"
			case .ownDeployEarnWXM:
				return "my_stations_own_deploy_earn_wxm"
			case .buyStation:
				return "my_stations_buy_station"
			case .followAStationInExplorer:
				return "my_stations_follow_a_station_in_explorer"
			case .claimYourStationhere:
				return "my_stations_claim_your_station_here"
		}
	}
}

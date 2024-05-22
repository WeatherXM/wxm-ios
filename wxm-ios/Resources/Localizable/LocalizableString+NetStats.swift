//
//  LocalizableString+NetStats.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/9/23.
//

import Foundation

extension LocalizableString {
    enum NetStats {
        case networkStatistics
        case weatherStationDays
        case lastDays(Int)
        case lastRun
        case wxmRewardsTitle
		case wxmRewardsDescriptionMarkdown(String)
        case totalSupply
        case dailyMinted
		case circulatingSupply
        case weatherStations
        case claimed
        case active
        case buyStationCardTitle
        case buyStationCardDescription(Float)
        case buyStationCardButtonTitle
        case buyStationCardInfoDescription
        case dataDaysInfoText
        case totalAllocatedInfoText
        case totalSupplyInfoText
        case dailyMintedInfoText
		case circulatingSupplyInfoText
        case totalWeatherStationsInfoTitle
        case claimedWeatherStationsInfoTitle
        case activeWeatherStationsInfoTitle
        case totalWeatherStationsInfoText
        case claimedWeatherStationsInfoText
        case activeWeatherStationsInfoText
        case emptyTitle
        case emptyDescription
        case manufacturerCTATitle
        case manufacturerCTADescription
        case manufacturerCTAButtonTitle
        case wxmTokenTitle
        case wxmTokenDescriptionMarkdown(String)
    }
}

extension LocalizableString.NetStats: WXMLocalizable {
    var localized: String {
        var localized = NSLocalizedString(self.key, comment: "")
        switch self {
            case .lastDays(let count):
                localized = String(format: localized, count)
            case .buyStationCardDescription(let count):
                localized = String(format: localized, count)
			case .wxmTokenDescriptionMarkdown(let text),
				 .wxmRewardsDescriptionMarkdown(let text):
                localized = String(format: localized, text)
            default:
                break
        }

        return localized
    }

    var key: String {
        switch self {
            case .networkStatistics:
                return "net_stats_network_statistics"
            case .weatherStationDays:
                return "net_stats_weather_station_days"
            case .lastDays:
                return "net_stats_last_days_format"
            case .lastRun:
                return "net_stats_last_run"
            case .wxmRewardsTitle:
                return "net_stats_wxm_rewards_tile"
			case .wxmRewardsDescriptionMarkdown:
				return "net_stats_wxm_rewards_description_markdown"
            case .totalSupply:
                return "net_stats_total_supply"
            case .dailyMinted:
                return "net_stats_daily_minted"
			case .circulatingSupply:
				return "net_stats_circulating_supply"
            case .weatherStations:
                return "net_stats_weather_stations"
            case .claimed:
                return "net_stats_claimed"
            case .active:
                return "net_stats_active"
            case .buyStationCardTitle:
                return "net_stats_buy_station_card_title"
            case .buyStationCardDescription:
                return "net_stats_buy_station_card_description_format"
            case .buyStationCardButtonTitle:
                return "net_stats_buy_station_card_button_title"
            case .buyStationCardInfoDescription:
                return "net_stats_buy_station_card_info_description"
            case .dataDaysInfoText:
                return "net_stats_data_days_info_text"
            case .totalAllocatedInfoText:
                return "net_stats_total_allocated_info_text"
            case .totalSupplyInfoText:
                return "net_stats_total_supply_info_text"
            case .dailyMintedInfoText:
                return "net_stats_daily_minted_info_text"
			case .circulatingSupplyInfoText:
				return "net_stats_circulating_supply_info_text"
            case .totalWeatherStationsInfoTitle:
                return "net_stats_total_weather_stations_info_title"
            case .claimedWeatherStationsInfoTitle:
                return "net_stats_claimed_weather_stations_info_title"
            case .activeWeatherStationsInfoTitle:
                return "net_stats_active_weather_stations_info_title"
            case .totalWeatherStationsInfoText:
                return "net_stats_total_weather_stations_info_text"
            case .claimedWeatherStationsInfoText:
                return "net_stats_claimed_weather_stations_info_text"
            case .activeWeatherStationsInfoText:
                return "net_stats_active_weather_stations_info_text"
            case .emptyTitle:
                return "net_stats_empty_tile"
            case .emptyDescription:
                return "net_stats_empty_description"
            case .manufacturerCTATitle:
                return "net_stats_manufacturer_cta_tile"
            case .manufacturerCTADescription:
                return "net_stats_manufacturer_cta_description"
            case .manufacturerCTAButtonTitle:
                return "net_stats_manufacturer_cta_button_title"
            case .wxmTokenTitle:
                return "net_stats_wxm_token_title"
            case .wxmTokenDescriptionMarkdown:
                return "net_stats_wxm_token_description_markdown"
        }
    }
}

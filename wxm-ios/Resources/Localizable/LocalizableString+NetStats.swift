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
		case networkStatisticsDescription
		case weatherStationDays
		case lastDays(Int)
		case lastRun
		case wxmRewardsTitle
		case wxmRewardsDescriptionMarkdown(String)
		case totalSupply
		case circulatingSupply
		case weatherStationsBreakdown
		case manufactured
		case claimed
		case deployed
		case claimedAmount(String)
		case reserved(String)
		case total(String)
		case active
		case tokenMetrics
		case buyStationCardTitle
		case buyStationCardDescription(Float)
		case buyStationCardButtonTitle
		case buyStationCardInfoDescription
		case dataDaysInfoText
		case dataQualityScore
		case dataQualityScoreInfoText
		case activeStations
		case activeStationsInfoText
		case networkUptime
		case deployYourStation
		case checkTheWeather
		case networkHealth
		case networkHealthInfoText
		case networkGrowth
		case networkSize
		case addedInLastXDays(Int)
		case networkScaleUp
		case earnWXM
		case enterWebThree
		case totalAllocatedInfoText
		case totalSupplyInfoText
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
		case totalWXMAllocated
		case totalWXMAllocatedInfo
		case totalWXMAllocatedDescription(String)
		case baseRewards
		case baseRewardsInfo
		case boostRewards
		case boostRewardsInfo
	}
}

extension LocalizableString.NetStats: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(self.key, comment: "")
		switch self {
			case .lastDays(let count),
					.addedInLastXDays(let count):
				localized = String(format: localized, count)
			case .buyStationCardDescription(let count):
				localized = String(format: localized, count)
			case .wxmTokenDescriptionMarkdown(let text),
					.claimedAmount(let text),
					.reserved(let text),
					.total(let text),
					.wxmRewardsDescriptionMarkdown(let text),
					.totalWXMAllocatedDescription(let text):
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
			case .networkStatisticsDescription:
				return "net_stats_network_statistics_description"
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
			case .circulatingSupply:
				return "net_stats_circulating_supply"
			case .weatherStationsBreakdown:
				return "net_stats_weather_stations_breakdown"
			case .manufactured:
				return "net_stats_manufactured"
			case .claimed:
				return "net_stats_claimed"
			case .deployed:
				return "net_stats_deployed"
			case .claimedAmount:
				return "net_stats_claimed_amount_format"
			case .reserved:
				return "net_stats_reserved_format"
			case .total:
				return "net_stats_total_format"
			case .active:
				return "net_stats_active"
			case .tokenMetrics:
				return "net_stats_token_metrics"
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
			case .dataQualityScore:
				return "net_stats_data_quality_score"
			case .dataQualityScoreInfoText:
				return "net_stats_data_quality_score_info_text"
			case .activeStations:
				return "net_stats_active_stations"
			case .activeStationsInfoText:
				return "net_stats_active_stations_info_text"
			case .networkUptime:
				return "net_stats_network_uptime"
			case .deployYourStation:
				return "net_stats_deploy_your_station"
			case .networkHealth:
				return "net_stats_network_health"
			case .networkHealthInfoText:
				return "net_stats_network_health_info_text"
			case .networkGrowth:
				return "net_stats_network_growth"
			case .networkSize:
				return "net_stats_network_size"
			case .addedInLastXDays:
				return "net_stats_added_in_last_x_days"
			case .networkScaleUp:
				return "net_stats_network_scale_up"
			case .checkTheWeather:
				return "net_stats_check_the_weather"
			case .earnWXM:
				return "net_stats_earn_wxm"
			case .enterWebThree:
				return "net_stats_enter_web3"
			case .totalAllocatedInfoText:
				return "net_stats_total_allocated_info_text"
			case .totalSupplyInfoText:
				return "net_stats_total_supply_info_text"
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
			case .totalWXMAllocated:
				return "net_stats_total_wxm_allocated"
			case .totalWXMAllocatedInfo:
				return "net_stats_total_wxm_allocated_info"
			case .totalWXMAllocatedDescription:
				return "net_stats_total_wxm_allocated_description"
			case .baseRewards:
				return "net_stats_base_rewards"
			case .baseRewardsInfo:
				return "net_stats_base_rewards_info"
			case .boostRewards:
				return "net_stats_boost_rewards"
			case .boostRewardsInfo:
				return "net_stats_boost_rewards_info"
		}
	}
}

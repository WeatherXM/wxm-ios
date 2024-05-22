//
//  NetworkStatsViewModel+Factory.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/7/23.
//

import Foundation
import DomainLayer
import Charts
import Toolkit
import SwiftUI

extension NetworkStatsViewModel {
    func getDataDaysStatistics(response: NetworkStatsResponse?) -> NetworkStatsView.Statistics? {
        guard let dataDays = fixedTimeSeries(timeSeries: response?.dataDays) else {
            return nil
        }
        let total = NetworkStatsView.AdditionalStats(title: LocalizableString.total(nil).localized,
                                                     value: dataDays.last?.value?.toCompactDecimaFormat ?? "",
                                                     color: .text,
                                                     info: nil,
                                                     analyticsItemId: nil)
        
        let count = dataDays.count
        let lastDataDayValue = dataDays.last?.value ?? 0.0
        let preLastDataDayValue = dataDays[safe: count - 2]?.value ?? 0.0
        let value = (lastDataDayValue - preLastDataDayValue).toCompactDecimaFormat ?? ""
        let preLastDay = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.lastRun.localized,
                                                          value: "+\(value)",
                                                          color: .reward_score_very_high,
                                                          info: nil,
                                                          analyticsItemId: nil)
        
        return getStatistics(from: dataDays,
                             title: LocalizableString.NetStats.weatherStationDays.localized,
                             info: (LocalizableString.NetStats.weatherStationDays.localized, LocalizableString.NetStats.dataDaysInfoText.localized),
                             additionalStats: [total, preLastDay],
                             analyticsItemId: .dataDays)
    }

    func getRewardsStatistics(response: NetworkStatsResponse?) -> NetworkStatsView.Statistics? {
        guard let tokens = response?.tokens,
				let allocatedPerDay = fixedTimeSeries(timeSeries: tokens.allocatedPerDay) else {
            return nil
        }
        let totalValue = allocatedPerDay.last?.value
        let total = NetworkStatsView.AdditionalStats(title: LocalizableString.total(nil).localized,
                                                     value: totalValue?.toCompactDecimaFormat ??  "",
                                                     info: nil,
                                                     analyticsItemId: nil)

        let count = allocatedPerDay.count
        let lastTokenValue = allocatedPerDay.last?.value ?? 0.0
        let preLastTokenValue = allocatedPerDay[safe: count - 2]?.value ?? 0.0
        let value = (lastTokenValue - preLastTokenValue).toCompactDecimaFormat ?? ""
        let lastDay = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.lastRun.localized,
                                                       value: "+\(value)",
                                                       color: .reward_score_very_high,
                                                       info: nil,
                                                       analyticsItemId: nil)

		let rewardsDescription = LocalizableString.NetStats.wxmRewardsDescriptionMarkdown(DisplayedLinks.rewardsContractAddress.linkURL).localized.attributedMarkdown

        return getStatistics(from: allocatedPerDay,
                             title: LocalizableString.NetStats.wxmRewardsTitle.localized,
							 description: rewardsDescription,
							 showExternalLinkIcon: true,
							 externalLinkTapAction: {},
                             info: (LocalizableString.NetStats.wxmRewardsTitle.localized, LocalizableString.NetStats.totalAllocatedInfoText.localized),
                             additionalStats: [total, lastDay],
                             analyticsItemId: .allocatedRewards)

    }

    func getTokenStatistics(response: NetworkStatsResponse?) -> NetworkStatsView.Statistics? {
        guard let tokens = response?.tokens else {
            return nil
        }

        let totalSupplyValue = tokens.totalSupply?.toCompactDecimaFormat ?? ""
        let totalSupply = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.totalSupply.localized,
                                                           value: totalSupplyValue,
                                                           info: nil,
                                                           analyticsItemId: nil)
        
        let dailyMintedValue = tokens.dailyMinted?.toCompactDecimaFormat ?? ""
        let dailyMinted = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.dailyMinted.localized,
                                                           value: "+\(dailyMintedValue)",
                                                           color: .reward_score_very_high,
                                                           info: nil,
                                                           analyticsItemId: nil)

        let tokenDescription = LocalizableString.NetStats.wxmTokenDescriptionMarkdown(DisplayedLinks.tokenContractAddress.linkURL).localized.attributedMarkdown
        return getStatistics(from: nil,
                             title: LocalizableString.NetStats.wxmTokenTitle.localized,
							 description: tokenDescription,
                             showExternalLinkIcon: true,
                             externalLinkTapAction: { Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .tokenomics]) },
                             info: nil,
                             additionalStats: [totalSupply, dailyMinted],
                             analyticsItemId: nil)
    }

    func getStationStats(response: NetworkStatsResponse?) -> [NetworkStatsView.StationStatistics]? {
        let sections = [(LocalizableString.total(nil).localized,
                         response?.weatherStations?.onboarded,
                         (LocalizableString.NetStats.totalWeatherStationsInfoTitle.localized, LocalizableString.NetStats.totalWeatherStationsInfoText.localized),
                         ParameterValue.total),
                        (LocalizableString.NetStats.claimed.localized,
                         response?.weatherStations?.claimed,
                         (LocalizableString.NetStats.claimedWeatherStationsInfoTitle.localized, LocalizableString.NetStats.claimedWeatherStationsInfoText.localized),
                         ParameterValue.claimed),
                        (LocalizableString.NetStats.active.localized,
                         response?.weatherStations?.active,
                         (LocalizableString.NetStats.activeWeatherStationsInfoTitle.localized, LocalizableString.NetStats.activeWeatherStationsInfoText.localized),
                         ParameterValue.active)]

        return sections.compactMap { title, stats, info, analyticsItemId in
            guard let stats else {
                return nil
            }

            return NetworkStatsView.StationStatistics(title: title,
                                                      total: stats.total?.localizedFormatted ?? "",
                                                      info: info,
                                                      details: stats.details?.map {
                NetworkStatsView.StationDetails(title: $0.model ?? "",
                                                value: $0.amount?.localizedFormatted ?? "",
                                                percentage: $0.percentage ?? 0.0,
                                                color: .chartSecondary,
                                                url: $0.url)} ?? [],
                                                      analyticsItemId: analyticsItemId)
        }
    }

    func getBuyStationCTA(response: NetworkStatsResponse?) -> NetworkStatsView.StatisticsCTA? {
		let description = LocalizableString.NetStats.buyStationCardDescription(Float(response?.tokens?.averageMonthly ?? 0.0)).localized
        let buyStationCTA = NetworkStatsView.StatisticsCTA(title: LocalizableString.NetStats.buyStationCardTitle.localized,
                                                           description: description,
                                                           info: (nil, LocalizableString.NetStats.buyStationCardInfoDescription.localized),
                                                           analyticsItemId: .buyStation,
                                                           buttonTitle: LocalizableString.NetStats.buyStationCardButtonTitle.localized,
                                                           buttonAction: { [weak self] in self?.handleBuyStationTap() })

        return buyStationCTA
    }

    func getManufacturerCTA(response: NetworkStatsResponse?) -> NetworkStatsView.StatisticsCTA? {
        let manufacturerCTA = NetworkStatsView.StatisticsCTA(title: LocalizableString.NetStats.manufacturerCTATitle.localized,
                                                             description: LocalizableString.NetStats.manufacturerCTADescription.localized,
                                                             info: nil,
                                                             analyticsItemId: nil,
                                                             buttonTitle: LocalizableString.NetStats.manufacturerCTAButtonTitle.localized,
                                                             buttonAction: {
            if let url = URL(string: DisplayedLinks.contactLink.linkURL) {
                UIApplication.shared.open(url)
            }
            Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .openManufacturerContact])
        })
        
        return manufacturerCTA
    }
}

private extension NetworkStatsViewModel {
    func getStatistics(from days: [NetworkStatsTimeSeries]?,
                       title: String,
                       description: AttributedString? = nil,
                       showExternalLinkIcon: Bool = false,
                       externalLinkTapAction: VoidCallback? = nil,
                       info: NetworkStatsView.InfoTuple?,
                       additionalStats: [NetworkStatsView.AdditionalStats]?,
                       analyticsItemId: ParameterValue?) -> NetworkStatsView.Statistics {
        var chartModel: NetStatsChartViewModel?
        var xAxisTuple: NetworkStatsView.XAxisTuple?
        var mainText: String?
        var dateString: String?

        if let days {
            let count = days.count
            let lastVal = days.last?.value ?? 0
            let firstVal = days.first?.value ?? 0
            let diff = lastVal - firstVal
            mainText = diff.toCompactDecimaFormat ?? "\(diff)"
            chartModel = NetStatsChartViewModel(entries: days.enumerated().map { ChartDataEntry(x: Double($0), y: Double($1.value ?? 0)) })
            xAxisTuple = (days.first?.ts?.getFormattedDate(format: .monthLiteralDay) ?? "", days.last?.ts?.getFormattedDate(format: .monthLiteralDay) ?? "")

			if let firstDate = days.first?.ts {
				let daysCount = Date.now.days(from: firstDate)
				dateString = LocalizableString.NetStats.lastDays(daysCount).localized
			}
        }

        return NetworkStatsView.Statistics(title: title,
                                           description: description,
                                           showExternalLinkIcon: showExternalLinkIcon,
                                           externalLinkTapAction: externalLinkTapAction,
                                           mainText: mainText,
                                           info: info,
                                           dateString: dateString,
                                           chartModel: chartModel,
                                           xAxisTuple: xAxisTuple,
                                           additionalStats: additionalStats,
                                           analyticsItemId: analyticsItemId)
    }

	func fixedTimeSeries(timeSeries: [NetworkStatsTimeSeries]?) -> [NetworkStatsTimeSeries]? {
		guard let timeSeries, let lastItem = timeSeries.last else {
			return nil
		}

		var dropCount = -1
		for item in timeSeries.reversed() {
			if lastItem.value == item.value {
				dropCount += 1
			} else {
				break
			}
		}

		return Array(timeSeries.dropLast(dropCount))
	}
}

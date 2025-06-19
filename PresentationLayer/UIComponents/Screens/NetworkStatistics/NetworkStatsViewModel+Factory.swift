//
//  NetworkStatsViewModel+Factory.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/7/23.
//

import Foundation
import DomainLayer
import DGCharts
import Toolkit
import SwiftUI

extension NetworkStatsViewModel {
    func getDataDaysStatistics(response: NetworkStatsResponse?) -> NetworkStatsView.Statistics? {
        guard let dataDays = fixedTimeSeries(timeSeries: response?.dataDays) else {
            return nil
        }
        let total = NetworkStatsView.AdditionalStats(title: LocalizableString.total(nil).localized,
                                                     value: dataDays.last?.value?.toCompactDecimaFormat ?? "?",
                                                     color: .text,
                                                     accessory: nil,
                                                     analyticsItemId: nil)
        
        let count = dataDays.count
        let lastDataDayValue = dataDays.last?.value ?? 0.0
        let preLastDataDayValue = dataDays[safe: count - 2]?.value ?? 0.0
        let value = (lastDataDayValue - preLastDataDayValue).toCompactDecimaFormat ?? "?"
        let preLastDay = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.lastRun.localized,
                                                          value: "+\(value)",
                                                          color: .reward_score_very_high,
                                                          accessory: nil,
                                                          analyticsItemId: nil)
		let accessory = NetworkStatsView.Accessory(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.weatherStationDays.localized,
						   description: LocalizableString.NetStats.dataDaysInfoText.localized,
						   analyticsItemId: .dataDays)
		}

        return getStatistics(from: dataDays,
                             title: LocalizableString.NetStats.weatherStationDays.localized,
                             accessory: accessory,
                             additionalStats: [total, preLastDay],
                             analyticsItemId: .dataDays)
    }

    func getRewardsStatistics(response: NetworkStatsResponse?) -> NetworkStatsView.Statistics? {
		guard let tokens = response?.rewards,
			  let allocatedPerDay = fixedTimeSeries(timeSeries: tokens.last30DaysGraph) else {
            return nil
        }
		let totalValue = tokens.total
        let total = NetworkStatsView.AdditionalStats(title: LocalizableString.total(nil).localized,
                                                     value: totalValue?.toCompactDecimaFormat ??  "?",
                                                     accessory: nil,
                                                     analyticsItemId: nil)

        let count = allocatedPerDay.count
        let lastTokenValue = allocatedPerDay.last?.value ?? 0.0
        let preLastTokenValue = allocatedPerDay[safe: count - 2]?.value ?? 0.0
        let value = (lastTokenValue - preLastTokenValue).toCompactDecimaFormat ?? "?"
        let lastDay = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.lastRun.localized,
                                                       value: "+\(value)",
                                                       color: .reward_score_very_high,
													   accessory: .init(fontIcon: .externalLink) {
			guard let txHashUrl = tokens.lastTxHashUrl else {
				return
			}
			WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .lastRunHash])

			LinkNavigationHelper().openUrl(txHashUrl)
		},
                                                       analyticsItemId: nil)

		var rewardsDescription: AttributedString?
		let url = DisplayedLinks.rewardMechanism.linkURL
		rewardsDescription = LocalizableString.NetStats.wxmRewardsDescriptionMarkdown(url).localized.attributedMarkdown

		let accessory = NetworkStatsView.Accessory(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.wxmRewardsTitle.localized,
						   description: LocalizableString.NetStats.totalAllocatedInfoText.localized,
						   analyticsItemId: .allocatedRewards)
		}

        return getStatistics(from: allocatedPerDay,
                             title: LocalizableString.NetStats.wxmRewardsTitle.localized,
							 description: rewardsDescription,
							 showExternalLinkIcon: true,
							 externalLinkTapAction: { WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .rewardContract]) },
                             accessory: accessory,
                             additionalStats: [total, lastDay],
							 analyticsItemId: .allocatedRewards) { [weak self] in
			guard let self else {
				return
			}
			self.router.navigateTo(.tokenMetrics(self))
		}
    }

	func getHealthStatistics(response: NetworkStatsResponse?) -> NetworkStatsView.Statistics? {
		guard let health = response?.health,
			  let timeSeries = fixedTimeSeries(timeSeries: health.health30DaysGraph) else {
			return nil
		}
		let qualityScore = Float(health.networkAvgQod ?? 0)
		let qod = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.dataQualityScore.localized,
												   value: LocalizableString.percentage(qualityScore).localized,
												   accessory: nil,
												   analyticsItemId: nil)

		let value = health.activeStations ?? 0
		let activeStations = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.activeStations.localized.uppercased(),
															  value: value.localizedFormatted,
															  accessory: nil,
															  analyticsItemId: nil)

		let accessory = NetworkStatsView.Accessory(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.wxmRewardsTitle.localized,
						   description: LocalizableString.NetStats.totalAllocatedInfoText.localized,
						   analyticsItemId: .allocatedRewards)
		}

		return getStatistics(from: timeSeries,
							 title: LocalizableString.NetStats.networkHealth.localized,
							 chartTitle: LocalizableString.NetStats.networkUptime.localized,
							 chartValueText: LocalizableString.percentage(Float(health.networkUptime ?? 0)).localized,
							 description: nil,
							 accessory: accessory,
							 additionalStats: [qod, activeStations],
							 analyticsItemId: .allocatedRewards)
	}


	func getTokenStatistics(response: NetworkStatsResponse?) -> NetworkStatsView.Statistics? {
		guard let tokens = response?.rewards?.tokenMetrics?.token else {
			return nil
		}

		let totalSupplyValue = tokens.totalSupply?.toCompactDecimaFormat ?? "?"
		let totalSupply = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.totalSupply.localized,
														   value: totalSupplyValue,
														   accessory: .init(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.totalSupply.localized,
						   description: LocalizableString.NetStats.totalSupplyInfoText.localized,
						   analyticsItemId: .totalSupply)
		},
														   analyticsItemId: .totalSupply)

		let circulatingSupplyValue = tokens.circulatingSupply?.toCompactDecimaFormat ?? "?"
		let circulatingSupply = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.circulatingSupply.localized,
																 value: circulatingSupplyValue,
																 accessory: .init(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.circulatingSupply.localized,
						   description: LocalizableString.NetStats.circulatingSupplyInfoText.localized,
						   analyticsItemId: .circulatingSupply)
		},
																 progress: tokens.supplyProgress,
																 analyticsItemId: .circulatingSupply)

		var tokenDescription: AttributedString?
		if let tokenUrl = response?.contracts?.tokenUrl {
			tokenDescription  = LocalizableString.NetStats.wxmTokenDescriptionMarkdown(tokenUrl).localized.attributedMarkdown
		}

		return getStatistics(from: nil,
							 title: LocalizableString.NetStats.wxmTokenTitle.localized,
							 description: tokenDescription,
							 showExternalLinkIcon: true,
							 externalLinkTapAction: { WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .tokenContract]) },
							 accessory: nil,
							 additionalStats: [totalSupply, circulatingSupply],
							 analyticsItemId: nil)
	}

    func getStationStats(response: NetworkStatsResponse?) -> [NetworkStatsView.StationStatistics]? {
		let total = (LocalizableString.total(nil).localized,
					 response?.weatherStations?.onboarded,
					 NetworkStatsView.Accessory(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.totalWeatherStationsInfoTitle.localized,
						   description: LocalizableString.NetStats.totalWeatherStationsInfoText.localized,
						   analyticsItemId: .total)
		},
					 ParameterValue.total)

		let claimed = (LocalizableString.NetStats.claimed.localized,
					   response?.weatherStations?.claimed,
					   NetworkStatsView.Accessory(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.claimedWeatherStationsInfoTitle.localized,
						   description: LocalizableString.NetStats.claimedWeatherStationsInfoText.localized,
						   analyticsItemId: .claimed)
		},

					   ParameterValue.claimed)

		let active = (LocalizableString.NetStats.active.localized,
					  response?.weatherStations?.active,
					  NetworkStatsView.Accessory(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.activeWeatherStationsInfoTitle.localized,
						   description: LocalizableString.NetStats.activeWeatherStationsInfoText.localized,
						   analyticsItemId: .active)
		},
					  ParameterValue.active)

        let sections = [total, claimed, active]

        return sections.compactMap { title, stats, info, analyticsItemId in
            guard let stats else {
                return nil
            }

            return NetworkStatsView.StationStatistics(title: title,
                                                      total: stats.total?.localizedFormatted ?? "",
                                                      accessory: info,
                                                      details: stats.details?.map {
                NetworkStatsView.StationDetails(title: $0.model ?? "",
                                                value: $0.amount?.localizedFormatted ?? "",
                                                percentage: $0.percentage ?? 0.0,
                                                color: .chartSecondary,
                                                url: $0.url)} ?? [],
                                                      analyticsItemId: analyticsItemId)
        }
    }

    func getManufacturerCTA(response: NetworkStatsResponse?) -> NetworkStatsView.StatisticsCTA? {
        let manufacturerCTA = NetworkStatsView.StatisticsCTA(title: LocalizableString.NetStats.manufacturerCTATitle.localized,
                                                             description: LocalizableString.NetStats.manufacturerCTADescription.localized,
                                                             accessory: nil,
                                                             analyticsItemId: nil,
                                                             buttonTitle: LocalizableString.NetStats.manufacturerCTAButtonTitle.localized,
                                                             buttonAction: {
            if let url = URL(string: DisplayedLinks.contactLink.linkURL) {
                UIApplication.shared.open(url)
            }
            WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .openManufacturerContact])
        })
        
        return manufacturerCTA
    }

	func getTotalAllocatedRewards(response: NetworkStatsResponse?) -> NetworkStatsView.Statistics? {
		guard let rewards = response?.rewards,
			  let totalAllocated = rewards.tokenMetrics?.totalAllocated else {
			return nil
		}

		let url = response?.rewards?.tokenMetrics?.totalAllocated?.dune?.dunePublicUrl ?? ""
		let description = LocalizableString.NetStats.totalWXMAllocatedDescription(url).localized.attributedMarkdown

		let baseRewardsAccessory = NetworkStatsView.Accessory(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.baseRewards.localized,
						   description: LocalizableString.NetStats.baseRewardsInfo.localized,
						   analyticsItemId: .baseRewards)
		}

		let baseRewards = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.baseRewards.localized,
														   value: totalAllocated.baseRewards?.toCompactDecimaFormat ??  "?",
														   accessory: baseRewardsAccessory,
														   analyticsItemId: nil)

		let boostRewardsAccessory = NetworkStatsView.Accessory(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.boostRewards.localized,
						   description: LocalizableString.NetStats.boostRewardsInfo.localized,
						   analyticsItemId: .boostRewards)
		}

		let boostRewards = NetworkStatsView.AdditionalStats(title: LocalizableString.NetStats.boostRewards.localized,
															value: totalAllocated.boostRewards?.toCompactDecimaFormat ??  "?",
															accessory: boostRewardsAccessory,
															analyticsItemId: nil)

		let accessory = NetworkStatsView.Accessory(fontIcon: .infoCircle) { [weak self] in
			self?.showInfo(title: LocalizableString.NetStats.totalWXMAllocated.localized,
						   description: LocalizableString.NetStats.totalWXMAllocatedInfo.localized,
						   analyticsItemId: .totalWXMAllocated)
		}

		return getStatistics(from: nil,
							 title: LocalizableString.NetStats.totalWXMAllocated.localized,
							 description: description,
							 showExternalLinkIcon: true,
							 externalLinkTapAction: { WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .networkStats,
																												  .source: .dune]) },
							 accessory: accessory,
							 customView: NetworkStatsDonutView(claimed: Double(totalAllocated.dune?.claimed ?? 0),
															   reserved: Double(totalAllocated.dune?.unclaimed ?? 0)).toAnyView,
							 additionalStats: [baseRewards, boostRewards],
							 analyticsItemId: nil)

	}
}

private extension NetworkStatsViewModel {
    func getStatistics(from days: [NetworkStatsTimeSeries]?,
                       title: String,
					   chartTitle: String? = nil,
					   chartValueText: String? = nil,
                       description: AttributedString? = nil,
                       showExternalLinkIcon: Bool = false,
                       externalLinkTapAction: VoidCallback? = nil,
                       accessory: NetworkStatsView.Accessory?,
					   customView: AnyView? = nil,
                       additionalStats: [NetworkStatsView.AdditionalStats]?,
                       analyticsItemId: ParameterValue?,
					   cardTapAction: VoidCallback? = nil) -> NetworkStatsView.Statistics {
        var chartModel: NetStatsChartViewModel?
        var xAxisTuple: NetworkStatsView.XAxisTuple?
		var mainText: String?
		var dateString: String? = chartTitle

		if let days {
            let lastVal = days.last?.value ?? 0
            let firstVal = days.first?.value ?? 0
            let diff = lastVal - firstVal
			mainText = chartValueText ?? diff.toCompactDecimaFormat ?? "\(diff)"
            chartModel = NetStatsChartViewModel(entries: days.enumerated().map { ChartDataEntry(x: Double($0), y: Double($1.value ?? 0)) })
            xAxisTuple = (days.first?.ts?.getFormattedDate(format: .monthLiteralDay) ?? "", days.last?.ts?.getFormattedDate(format: .monthLiteralDay) ?? "")

			if let firstDate = days.first?.ts, chartTitle == nil {
				let daysCount = Date.now.days(from: firstDate)
				dateString = LocalizableString.NetStats.lastDays(daysCount).localized
			}
        }

        return NetworkStatsView.Statistics(title: title,
                                           description: description,
                                           showExternalLinkIcon: showExternalLinkIcon,
                                           externalLinkTapAction: externalLinkTapAction,
                                           mainText: mainText,
                                           accessory: accessory,
                                           dateString: dateString,
                                           chartModel: chartModel,
                                           xAxisTuple: xAxisTuple,
                                           additionalStats: additionalStats,
                                           analyticsItemId: analyticsItemId,
										   cardTapAction: cardTapAction,
										   customView: customView)
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

//
//  RewardAnalyticsChartFactory.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/9/24.
//

import Foundation
import DomainLayer
import Toolkit

struct RewardAnalyticsChartFactory {
	typealias ChartData = (dataItems: [ChartDataItem], legendItems: [ChartLegendView.Item])

	func getChartsData(overallResponse: NetworkDevicesRewardsResponse, mode: DeviceRewardsMode) -> [ChartDataItem] {
		switch mode {
			case .week:
				getSevendaysMode(overallResponse: overallResponse)
			case .month:
				getMonthlyMode(overallResponse: overallResponse)
			case .year:
				getYearlyMode(overallResponse: overallResponse)
		}
	}

	func getChartsData(deviceResponse: NetworkDeviceRewardsResponse, mode: DeviceRewardsMode) -> ChartData {
		switch mode {
			case .week:
				getSevendaysMode(deviceResponse: deviceResponse)
			case .month:
				getMonthlyMode(deviceResponse: deviceResponse)
			case .year:
				getYearlyMode(deviceResponse: deviceResponse)
		}
	}
}

private extension RewardAnalyticsChartFactory {
	// MARK: - Overall
	
	func getSevendaysMode(overallResponse: NetworkDevicesRewardsResponse) -> [ChartDataItem] {
		getDataItems(overallResponse: overallResponse) { date in
			date.getWeekDay()
		}
	}

	func getMonthlyMode(overallResponse: NetworkDevicesRewardsResponse) -> [ChartDataItem] {
		getDataItems(overallResponse: overallResponse) { date in
			date.getFormattedDate(format: .monthDay)
		}
	}

	func getYearlyMode(overallResponse: NetworkDevicesRewardsResponse) -> [ChartDataItem] {
		getDataItems(overallResponse: overallResponse) { date in
			date.getMonth()
		}
	}

	func getDataItems(overallResponse: NetworkDevicesRewardsResponse,
					  xAxisLabel: GenericValueCallback<Date, String>) -> [ChartDataItem] {
		var counter = -1

		return overallResponse.data?.compactMap { datum in
			counter += 1

			guard let ts = datum.ts else {
				return nil
			}
			return ChartDataItem(xVal: counter,
								 yVal: datum.totalRewards ?? 0.0,
								 xAxisLabel: xAxisLabel(ts),
								 group: LocalizableString.total(nil).localized,
								 displayValue: (datum.totalRewards ?? 0.0).toWXMTokenPrecisionString)
		} ?? []
	}

	// MARK: - Device

	func getSevendaysMode(deviceResponse: NetworkDeviceRewardsResponse) -> ChartData {
		getDataItems(deviceResponse: deviceResponse) { date in
			date.getWeekDay()
		}
	}

	func getMonthlyMode(deviceResponse: NetworkDeviceRewardsResponse) -> ChartData {
		getDataItems(deviceResponse: deviceResponse) { date in
			date.getFormattedDate(format: .monthDay)
		}
	}

	func getYearlyMode(deviceResponse: NetworkDeviceRewardsResponse) -> ChartData {
		getDataItems(deviceResponse: deviceResponse) { date in
			date.getMonth()
		}
	}

	func getDataItems(deviceResponse: NetworkDeviceRewardsResponse,
					  xAxisLabel: GenericValueCallback<Date, String>) -> ChartData {
		var chartDataItems: [ChartDataItem] = []
		var legendItems: [ChartLegendView.Item] = []

		var counter = -1
		deviceResponse.data?.forEach { datum in
			counter += 1

			guard let ts = datum.ts, let rewards = datum.rewards else {
				return
			}

			rewards.forEach { item in
				let dataItem = ChartDataItem(xVal: counter,
											 yVal: item.value ?? 0.0,
											 xAxisLabel: xAxisLabel(ts),
											 group: item.displayName ?? "",
											 color: item.chartColor ?? .chartPrimary,
											 displayValue: (item.value ?? 0.0).toWXMTokenPrecisionString)
				chartDataItems.append(dataItem)

				let legendItem = ChartLegendView.Item(color: item.chartColor ?? .chartPrimary, title: item.legendTitle ?? "")
				legendItems.append(legendItem)
			}
			
		}

		return (chartDataItems, legendItems.withNoDuplicates)
	}
}

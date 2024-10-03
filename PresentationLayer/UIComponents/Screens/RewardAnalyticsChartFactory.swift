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
			(date.getWeekDay(), date.getWeekDay(.wide))
		}
	}

	func getMonthlyMode(overallResponse: NetworkDevicesRewardsResponse) -> [ChartDataItem] {
		getDataItems(overallResponse: overallResponse) { date in
			(date.getFormattedDate(format: .monthDayShort, localized: true),
			 date.getFormattedDate(format: .monthLiteralDay, localized: true).capitalized)
		}
	}

	func getYearlyMode(overallResponse: NetworkDevicesRewardsResponse) -> [ChartDataItem] {
		getDataItems(overallResponse: overallResponse) { date in
			(date.getMonth(), date.getMonth(.wide))
		}
	}

	func getDataItems(overallResponse: NetworkDevicesRewardsResponse,
					  xAxisLabels: GenericValueCallback<Date, (String, String)>) -> [ChartDataItem] {
		var counter = -1

		return overallResponse.data?.compactMap { datum in
			counter += 1

			guard let ts = datum.ts else {
				return nil
			}
			let xLabels = xAxisLabels(ts)
			return ChartDataItem(xVal: counter,
								 yVal: datum.totalRewards ?? 0.0,
								 xAxisLabel: xLabels.0,
								 xAxisDisplayLabel: xLabels.1,
								 group: LocalizableString.total(nil).localized,
								 displayValue: (datum.totalRewards ?? 0.0).toWXMTokenPrecisionString)
		} ?? []
	}

	// MARK: - Device

	func getSevendaysMode(deviceResponse: NetworkDeviceRewardsResponse) -> ChartData {
		getDataItems(deviceResponse: deviceResponse) { date in
			(date.getWeekDay(), date.getWeekDay(.wide))
		}
	}

	func getMonthlyMode(deviceResponse: NetworkDeviceRewardsResponse) -> ChartData {
		getDataItems(deviceResponse: deviceResponse) { date in
			(date.getFormattedDate(format: .monthDayShort, localized: true),
			 date.getFormattedDate(format: .monthLiteralDay, localized: true).capitalized)
		}
	}

	func getYearlyMode(deviceResponse: NetworkDeviceRewardsResponse) -> ChartData {
		getDataItems(deviceResponse: deviceResponse) { date in
			(date.getMonth(), date.getMonth(.wide))
		}
	}

	func getDataItems(deviceResponse: NetworkDeviceRewardsResponse,
					  xAxisLabels: GenericValueCallback<Date, (String, String)>) -> ChartData {
		var chartDataItems: [ChartDataItem] = []
		var legendItems: [ChartLegendView.Item] = []

		var counter = -1
		deviceResponse.data?.forEach { datum in
			counter += 1

			guard let ts = datum.ts, let rewards = datum.rewards else {
				return
			}

			let xLabels = xAxisLabels(ts)
			rewards.withMergedUnknownBoosts.forEach { item in
				let dataItem = ChartDataItem(xVal: counter,
											 yVal: item.value ?? 0.0,
											 xAxisLabel: xLabels.0,
											 xAxisDisplayLabel: xLabels.1,
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

private extension Array where Element == NetworkDeviceRewardsResponse.RewardItem {
	var withMergedUnknownBoosts: Self {
		var validItems = self.filter {
			if $0.type == .boost, case .unknown = $0.code {
				return false
			}
			return true
		}
		let unknownItems: Self = self.filter {
			if $0.type == .boost, case .unknown = $0.code {
				return true
			}
			return false
		}

		guard !unknownItems.isEmpty else {
			return self
		}

		let unknownSummary = unknownItems.reduce(0) { $0 + ($1.value ?? 0.0) }
		let mergedItem = NetworkDeviceRewardsResponse.RewardItem(type: .boost,
																 code: unknownItems.first?.code,
																 value: unknownSummary)
		validItems.append(mergedItem)

		return validItems
	}
}

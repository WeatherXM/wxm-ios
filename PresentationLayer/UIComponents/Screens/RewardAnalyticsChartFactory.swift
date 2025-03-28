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
		let legendItems: [ChartLegendView.Item] = deviceResponse.data?.legendItems ?? []

		var counter = -1
		deviceResponse.data?.forEach { datum in
			counter += 1

			guard let ts = datum.ts, let rewards = datum.rewards else {
				return
			}

			let xLabels = xAxisLabels(ts)
			let withMergedDuplicates = rewards.withMergedDuplicates
			withMergedDuplicates.forEach { item in
				let dataItem = ChartDataItem(xVal: counter,
											 yVal: item.value ?? 0.0,
											 xAxisLabel: xLabels.0,
											 xAxisDisplayLabel: xLabels.1,
											 group: item.displayName ?? "",
											 color: item.chartColor ?? .chartPrimary,
											 displayValue: (item.value ?? 0.0).toWXMTokenPrecisionString)
				chartDataItems.append(dataItem)
			}
		}

		return (chartDataItems, legendItems)
	}
}

private extension Array where Element == NetworkDeviceRewardsResponse.RewardItem {
	var withMergedDuplicates: Self {
		let dict = Dictionary(grouping: self) { $0.sortIdentifier }

		return dict.values.map { elements in
			let sum = elements.reduce(0) { $0 + ($1.value ?? 0.0) }
			let firstItem = elements.first
			let mergedItem = NetworkDeviceRewardsResponse.RewardItem(type: firstItem?.type,
																	 code: firstItem?.code,
																	 value: sum)
			return mergedItem
		}
		.sortedByCriteria(criterias: [{ ($0.type?.index ?? 0) < ($1.type?.index ?? 0) },
									  { ($0.code ?? .unknown("")) < ($1.code ?? .unknown("")) }])

	}
}

private extension NetworkDeviceRewardsResponse.RewardItem {
	var sortIdentifier: String {
		guard type == .boost else {
			return type?.rawValue ?? ""
		}

		if case .unknown = code {
			return "\(type?.rawValue ?? "")-unknown"
		}

		return "\(type?.rawValue ?? "")-\(code?.rawValue ?? "")"
	}
}

private extension Array where Element ==  NetworkDeviceRewardsResponse.RewardsData {
	var legendItems: [ChartLegendView.Item] {
		let items: [NetworkDeviceRewardsResponse.RewardItem]? = self.compactMap { $0.rewards }.flatMap { $0 }.sortedByCriteria(criterias:  [{ ($0.type?.index ?? 0) < ($1.type?.index ?? 0) },
																																	{ ($0.code ?? .unknown("")) < ($1.code ?? .unknown("")) }])
		return items?.map { ChartLegendView.Item(color: $0.chartColor ?? .chartPrimary, title: $0.legendTitle ?? "")}.withNoDuplicates ?? []
	}
}

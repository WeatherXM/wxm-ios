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

	func getChartsData(deviceResponse: NetworkDeviceRewardsResponse, mode: DeviceRewardsMode) -> [ChartDataItem] {
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
								 displayValue: (datum.totalRewards ?? 0.0).toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency)
		} ?? []
	}

	// MARK: - Device

	func getSevendaysMode(deviceResponse: NetworkDeviceRewardsResponse) -> [ChartDataItem] {
		getDataItems(deviceResponse: deviceResponse) { date in
			date.getWeekDay()
		}
	}

	func getMonthlyMode(deviceResponse: NetworkDeviceRewardsResponse) -> [ChartDataItem] {
		getDataItems(deviceResponse: deviceResponse) { date in
			date.getFormattedDate(format: .monthDay)
		}
	}

	func getYearlyMode(deviceResponse: NetworkDeviceRewardsResponse) -> [ChartDataItem] {
		getDataItems(deviceResponse: deviceResponse) { date in
			date.getMonth()
		}
	}

	func getDataItems(deviceResponse: NetworkDeviceRewardsResponse,
					  xAxisLabel: GenericValueCallback<Date, String>) -> [ChartDataItem] {
		var counter = -1

		let items: [[ChartDataItem]]? = deviceResponse.data?.compactMap { datum in
			counter += 1

			guard let ts = datum.ts else {
				return nil
			}

			return datum.rewards?.map { item in
				return ChartDataItem(xVal: counter,
									 yVal: item.value ?? 0.0,
									 xAxisLabel: xAxisLabel(ts),
									 group: item.code?.displayName ?? "",
									 color: item.code?.fillColor ?? .chartPrimary,
									 displayValue: (item.value ?? 0.0).toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency)
			}
		}

		return items?.flatMap { $0 } ?? []
	}
}

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
		return overallResponse.data?.compactMap { datum in
			guard let ts = datum.ts else {
				return nil
			}
			return ChartDataItem(xVal: ts.day,
								 yVal: datum.totalRewards ?? 0.0,
								 xAxisLabel: ts.getWeekDay(),
								 group: LocalizableString.total(nil).localized,
								 displayValue: (datum.totalRewards ?? 0.0).toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency)
		} ?? []
	}

	func getMonthlyMode(overallResponse: NetworkDevicesRewardsResponse) -> [ChartDataItem] {
		[]
	}

	func getYearlyMode(overallResponse: NetworkDevicesRewardsResponse) -> [ChartDataItem] {
		[]
	}

	// MARK: - Device

	func getSevendaysMode(deviceResponse: NetworkDeviceRewardsResponse) -> [ChartDataItem] {
		let items: [[ChartDataItem]]? = deviceResponse.data?.compactMap { datum in
			guard let ts = datum.ts else {
				return nil
			}

			return datum.rewards?.map { item in
				return ChartDataItem(xVal: ts.day,
									 yVal: item.value ?? 0.0,
									 xAxisLabel: ts.getWeekDay(),
									 group: item.code?.displayName ?? "",
									 color: item.code?.fillColor ?? .chartPrimary,
									 displayValue: (item.value ?? 0.0).toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency)
			}
		}

		return items?.flatMap { $0 } ?? []
	}

	func getMonthlyMode(deviceResponse: NetworkDeviceRewardsResponse) -> [ChartDataItem] {
		[]
	}

	func getYearlyMode(deviceResponse: NetworkDeviceRewardsResponse) -> [ChartDataItem] {
		[]
	}

}

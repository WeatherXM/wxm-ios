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
}

private extension RewardAnalyticsChartFactory {
	func getSevendaysMode(overallResponse: NetworkDevicesRewardsResponse) -> [ChartDataItem] {
		var counter = -1
		return overallResponse.data?.map { datum in
			counter += 1
			return ChartDataItem(xVal: counter, yVal: datum.totalRewards ?? 2.0, group: datum.ts?.getWeekDay() ?? "")
		} ?? []
	}

	func getMonthlyMode(overallResponse: NetworkDevicesRewardsResponse) -> [ChartDataItem] {
		[]
	}

	func getYearlyMode(overallResponse: NetworkDevicesRewardsResponse) -> [ChartDataItem] {
		[]
	}
}

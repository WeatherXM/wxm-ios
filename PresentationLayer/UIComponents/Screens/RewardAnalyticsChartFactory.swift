//
//  RewardAnalyticsChartFactory.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 5/9/24.
//

import Foundation
import DomainLayer

struct RewardAnalyticsChartFactory {
	func getChartsData(overallResponse: NetworkDevicesResponse, mode: DeviceRewardsMode) -> [ChartDataItem] {
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
	func getSevendaysMode(overallResponse: NetworkDevicesResponse) -> [ChartDataItem] {
		[]
	}

	func getMonthlyMode(overallResponse: NetworkDevicesResponse) -> [ChartDataItem] {
		[]
	}

	func getYearlyMode(overallResponse: NetworkDevicesResponse) -> [ChartDataItem] {
		[]
	}
}

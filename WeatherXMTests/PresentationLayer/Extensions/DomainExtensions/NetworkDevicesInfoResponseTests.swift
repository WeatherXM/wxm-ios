//
//  NetworkDevicesInfoResponseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@MainActor
struct NetworkDevicesInfoResponseTests {

	@Test
	func batteryStateDescription() {
		#expect(BatteryState.low.description == LocalizableString.low.localized)
		#expect(BatteryState.ok.description == LocalizableString.good.localized)
	}

	@Test
	func isRewardSplittedWhenNil() {
		let response = NetworkDevicesInfoResponse(rewardSplit: nil)
		#expect(!response.isRewardSplitted)
	}

	@Test
	func isRewardSplittedWhenOne() {
		let splits = [RewardSplit(stake: 0.3, wallet: "", reward: 1.23)]
		let response = NetworkDevicesInfoResponse(rewardSplit: splits)
		#expect(!response.isRewardSplitted)
	}

	@Test
	func isRewardSplittedWhenTwo() {
		let splits = [RewardSplit(stake: 0.3, wallet: "", reward: 1.23),
					  RewardSplit(stake: 0.7, wallet: "", reward: 2.23)]
		let response = NetworkDevicesInfoResponse(rewardSplit: splits)
		#expect(response.isRewardSplitted)
	}
}

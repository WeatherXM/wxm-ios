//
//  NetworkDeviceRewardsResponseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

struct NetworkDeviceRewardsResponseTests {

	@Test
	func chartColor() {
		let baseItem = NetworkDeviceRewardsResponse.RewardItem(type: .base, code: nil, value: 1.0)
		#expect(baseItem.chartColor == .chartPrimary)

		let boostItem = NetworkDeviceRewardsResponse.RewardItem(type: .boost, code: .betaReward, value: 2.0)
		#expect(boostItem.chartColor == .betaRewardsPrimary)

		let unknownBoost = NetworkDeviceRewardsResponse.RewardItem(type: .boost, code: .unknown("custom"), value: 2.0)
		#expect(unknownBoost.chartColor == .otherRewardChart)

		let nilType = NetworkDeviceRewardsResponse.RewardItem(type: nil, code: .betaReward, value: 1.0)
		#expect(nilType.chartColor == nil)
	}

	@Test
	func displayName() {
		let baseItem = NetworkDeviceRewardsResponse.RewardItem(type: .base, code: nil, value: 1.0)
		#expect(baseItem.displayName == LocalizableString.RewardAnalytics.base.localized)

		let boostItem = NetworkDeviceRewardsResponse.RewardItem(type: .boost, code: .betaReward, value: 2.0)
		#expect(boostItem.displayName == LocalizableString.RewardAnalytics.beta.localized)

		let unknownBoost = NetworkDeviceRewardsResponse.RewardItem(type: .boost, code: .unknown("custom"), value: 2.0)
		#expect(unknownBoost.displayName == LocalizableString.RewardAnalytics.otherBoost.localized)

		let nilType = NetworkDeviceRewardsResponse.RewardItem(type: nil, code: .betaReward, value: 1.0)
		#expect(nilType.displayName == nil)
	}

	@Test
	func legendTitle() {
		let baseItem = NetworkDeviceRewardsResponse.RewardItem(type: .base, code: nil, value: 1.0)
		#expect(baseItem.legendTitle == LocalizableString.RewardAnalytics.baseRewards.localized)

		let boostItem = NetworkDeviceRewardsResponse.RewardItem(type: .boost, code: .betaReward, value: 2.0)
		#expect(boostItem.legendTitle == LocalizableString.RewardAnalytics.betaRewards.localized)

		let unknownBoost = NetworkDeviceRewardsResponse.RewardItem(type: .boost, code: .unknown("custom"), value: 2.0)
		#expect(unknownBoost.legendTitle == LocalizableString.RewardAnalytics.otherRewards.localized)

		let nilType = NetworkDeviceRewardsResponse.RewardItem(type: nil, code: .betaReward, value: 1.0)
		#expect(nilType.legendTitle == nil)
	}

	@Test
	func deviceRewardsModeDescription() {
		#expect(DeviceRewardsMode.week.description == LocalizableString.RewardAnalytics.weekAbbrevation.localized)
		#expect(DeviceRewardsMode.month.description == LocalizableString.RewardAnalytics.monthAbbrevation.localized)
		#expect(DeviceRewardsMode.year.description == LocalizableString.RewardAnalytics.yearAbbrevation.localized)
	}

	@Test
	func boostStartDateString() {
		let date = Date(timeIntervalSince1970: 1_700_000_000)
		let details = NetworkDeviceRewardsResponse.Details(
			code: .betaReward,
			currentRewards: 1.0,
			totalRewards: 2.0,
			boostPeriodStart: date,
			boostPeriodEnd: date,
			completedPercentage: 50
		)
		let expectedString = date.getFormattedDate(format: .monthLiteralDayYear, timezone: .UTCTimezone).capitalized
		#expect(details.boostStartDateString == expectedString)
		#expect(details.boostStopDateString == expectedString)

		let detailsNil = NetworkDeviceRewardsResponse.Details(
			code: .betaReward,
			currentRewards: 1.0,
			totalRewards: 2.0,
			boostPeriodStart: nil,
			boostPeriodEnd: nil,
			completedPercentage: 50
		)
		#expect(detailsNil.boostStartDateString == "")
		#expect(detailsNil.boostStopDateString == "")
	}
}


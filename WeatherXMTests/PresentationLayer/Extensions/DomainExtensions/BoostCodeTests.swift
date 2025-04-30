//
//  BoostCodeTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

struct BoostCodeTests {

	@Test
	func displayName() {
		#expect(BoostCode.betaReward.displayName == LocalizableString.RewardAnalytics.beta.localized)
		#expect(BoostCode.unknown("custom").displayName == LocalizableString.RewardAnalytics.otherBoost.localized)
	}

	@Test
	func primaryColor() {
		#expect(BoostCode.betaReward.primaryColor == .betaRewardsPrimary)
		#expect(BoostCode.unknown("custom").primaryColor == .otherRewardPrimary)
	}

	@Test
	func fillColor() {
		#expect(BoostCode.betaReward.fillColor == .betaRewardsFill)
		#expect(BoostCode.unknown("custom").fillColor == .otherRewardFill)
	}

	@Test
	func chartColor() {
		#expect(BoostCode.betaReward.chartColor == .betaRewardsPrimary)
		#expect(BoostCode.unknown("custom").chartColor == .otherRewardChart)
	}

	@Test
	func legendTitle() {
		#expect(BoostCode.betaReward.legendTitle == LocalizableString.RewardAnalytics.betaRewards.localized)
		#expect(BoostCode.unknown("custom").legendTitle == LocalizableString.RewardAnalytics.otherRewards.localized)
	}
}

//
//  DeviceRewardsOverviewTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

struct DeviceRewardsOverviewTests {
	func testSeverityComparable() {
		#expect(RewardAnnotation.Severity.error < RewardAnnotation.Severity.warning)
		#expect(RewardAnnotation.Severity.warning < RewardAnnotation.Severity.info)
		#expect(RewardAnnotation.Severity.error < RewardAnnotation.Severity.info)
		#expect(RewardAnnotation.Severity.info > RewardAnnotation.Severity.error)
		#expect(RewardAnnotation.Severity.info == RewardAnnotation.Severity.info)
	}

	@Test
	func testToCardWarningType() {
		#expect(RewardAnnotation.Severity.info.toCardWarningType == CardWarningType.info)
		#expect(RewardAnnotation.Severity.warning.toCardWarningType == CardWarningType.warning)
		#expect(RewardAnnotation.Severity.error.toCardWarningType == CardWarningType.error)
	}
}

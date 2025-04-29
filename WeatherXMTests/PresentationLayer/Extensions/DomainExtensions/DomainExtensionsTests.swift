//
//  DomainExtensionsTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

struct DomainExtensionsTests {

	@Test
	func explorerLocationErrorDescription() {
		#expect(ExplorerLocationError.locationNotFound.description == LocalizableString.explorerLocationNotFound.localized)
		#expect(ExplorerLocationError.permissionDenied.description == "")
	}

	@Test
	func networkStationsStatsTokensSupplyProgress() {
		var tokens = NetworkStationsStatsTokens(totalSupply: 1000,
												circulatingSupply: 250,
												totalAllocated: nil,
												allocatedPerDay: nil,
												lastTxHashUrl: nil,
												averageMonthly: nil)
		#expect(tokens.supplyProgress == 0.25)

		tokens = NetworkStationsStatsTokens(totalSupply: nil,
											circulatingSupply: 250,
											totalAllocated: nil,
											allocatedPerDay: nil,
											lastTxHashUrl: nil,
											averageMonthly: nil)
		#expect(tokens.supplyProgress == nil)

		tokens = NetworkStationsStatsTokens(totalSupply: 1000,
											circulatingSupply: nil,
											totalAllocated: nil,
											allocatedPerDay: nil,
											lastTxHashUrl: nil,
											averageMonthly: nil)
		#expect(tokens.supplyProgress == nil)

		tokens = NetworkStationsStatsTokens(totalSupply: 0,
											circulatingSupply: 100,
											totalAllocated: nil,
											allocatedPerDay: nil,
											lastTxHashUrl: nil,
											averageMonthly: nil)
		#expect(tokens.supplyProgress?.isInfinite == true)
	}

	@Test
	func toAnnouncementConfiguration() {
		let survey = Survey(id: nil,
							title: "Test Title",
							message: "Test Message",
							actionLabel: nil,
							url: nil)
		let config = survey.toAnnouncementConfiguration(actionTitle: "Action", action: {}, closeAction: {})
		#expect(config?.title == "Test Title")
		#expect(config?.description == "Test Message")
		#expect(config?.actionTitle == "Action")
		#expect(config?.action != nil)
		#expect(config?.closeAction != nil)
	}
}

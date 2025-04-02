//
//  HistoryContainerViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

struct HistoryContainerViewModelTests {

    @Test func normalState() async throws {
		let device = DeviceDetails(name: "Test Device",
								   isActive: true,
								   claimedAt: Date().advancedByDays(days: -10).toTimestamp())
		let viewModel: HistoryContainerViewModel = .init(device: device)

		#expect(viewModel.currentDate != nil)
		#expect(viewModel.currentDate == viewModel.historyDates.last)
		#expect(viewModel.historyDates.count == 11)
		#expect(viewModel.historyDates.first?.day == Date().advancedByDays(days: -10).day)
    }

	@Test func noClaimDate() {
		let device = DeviceDetails(name: "Test Device",
								   isActive: true)
		let viewModel: HistoryContainerViewModel = .init(device: device)
		#expect(viewModel.currentDate != nil)
		#expect(viewModel.currentDate == viewModel.historyDates.last)
		#expect(viewModel.historyDates.count == 7)
		#expect(viewModel.historyDates.first?.day == Date().advancedByDays(days: -6).day)
	}
}

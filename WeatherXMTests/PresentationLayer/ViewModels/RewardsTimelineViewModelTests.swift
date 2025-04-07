//
//  RewardsTimelineViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@Suite(.serialized)
@MainActor
struct RewardsTimelineViewModelTests {
	let viewModel: RewardsTimelineViewModel
	let useCase: MockRewardsTimelineUseCase

	init() {
		useCase = MockRewardsTimelineUseCase()
		viewModel = RewardsTimelineViewModel(device: DeviceDetails.mockDevice,
											 followState: nil,
											 useCase: useCase)
	}

    @Test func initialState() async throws {
		#expect(viewModel.transactions.isEmpty)
		try await Task.sleep(for: .seconds(1))
		#expect(viewModel.transactions.count == 1)
    }

	@Test func fetchMore() async throws {
		#expect(viewModel.transactions.isEmpty)
		try await Task.sleep(for: .seconds(1))
		let lastSummary = try #require(viewModel.transactions.last?.last)
		viewModel.fetchNextPageIfNeeded(for: lastSummary)
		try await Task.sleep(for: .seconds(1))
		#expect(viewModel.transactions.last?.last == lastSummary)
	}
}

//
//  RewardDetailsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@Suite(.serialized)
@MainActor
struct RewardDetailsViewModelTests {
	let viewModel: RewardDetailsViewModel
	let rewardsTimelineUseCase: MockRewardsTimelineUseCase

	init() {
		let device = DeviceDetails.mockDevice
		let followState: UserDeviceFollowState? = nil
		let date = Date()
		rewardsTimelineUseCase = .init()
		viewModel = .init(device: device, followState: followState, date: date, tokenUseCase: rewardsTimelineUseCase)
	}

	@Test func refresh() async throws {
		try await Task.sleep(for: .seconds(1))
		#expect(viewModel.rewardDetailsResponse != nil)
		#expect(viewModel.state == .content)
	}

	@Test func issuesTitle() async throws {
		try await Task.sleep(for: .seconds(1))
		#expect(viewModel.issuesSubtitle() == LocalizableString.StationDetails.stationRewardErrorMessage(1).localized)

		#expect(viewModel.issuesButtonTitle() == nil)
	}

	@Test func handleSplitButtonTap() {
		#expect(!viewModel.showSplits)
		viewModel.handleSplitButtonTap()
		#expect(viewModel.showSplits)
	}

	@Test func handleDailyRewardInfoTap() {
		#expect(!viewModel.showInfo)
		viewModel.handleDailyRewardInfoTap()
		#expect(viewModel.showInfo)
		// Add assertions to verify the daily reward info tap logic
	}

	@Test func handleDataQualityInfoTap() {
		#expect(!viewModel.showInfo)
		viewModel.handleDataQualityInfoTap()
		#expect(viewModel.showInfo)
	}

	@Test func handleLocationQualityInfoTap() {
		#expect(!viewModel.showInfo)
		viewModel.handleLocationQualityInfoTap()
		#expect(viewModel.showInfo)
	}

	@Test func handleCellPositionInfoTap() {
		#expect(!viewModel.showInfo)
		viewModel.handleCellPositionInfoTap()
		#expect(viewModel.showInfo)
	}
}

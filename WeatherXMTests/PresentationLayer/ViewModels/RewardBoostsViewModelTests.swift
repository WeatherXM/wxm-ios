//
//  RewardBoostsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 4/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@Suite(.serialized)
@MainActor
struct RewardBoostsViewModelTests {
	let viewModel: RewardBoostsViewModel
	let useCase: MockRewardsTimelineUseCase
	let linkNavigation: MockLinkNavigation
	private let docUrl = "http://example.com"

	init() {
		let boostReward = NetworkDeviceRewardDetailsResponse.BoostReward(code: .betaReward,
																		 title: nil,
																		 description: nil,
																		 imageUrl: nil,
																		 docUrl: docUrl,
																		 actualReward: 0,
																		 rewardScore: 0,
																		 maxReward: nil)
		let device = DeviceDetails.mockDevice
		useCase = .init()
		linkNavigation = .init()
		viewModel = .init(boost: boostReward, device: device, date: nil, useCase: useCase, linkNavigation: linkNavigation)
	}

	@Test func refresh() async throws {
		try await Task.sleep(for: .seconds(2))
		#expect(viewModel.state == .content)
		#expect(viewModel.response != nil)
	}

	@Test func handleReadMoreTap() async throws {
		try await Task.sleep(for: .seconds(1))
		#expect(linkNavigation.openedUrl == nil)
		viewModel.handleReadMoreTap()
		#expect(linkNavigation.openedUrl == docUrl)
	}
}

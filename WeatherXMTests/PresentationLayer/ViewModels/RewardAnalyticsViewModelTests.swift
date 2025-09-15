//
//  RewardAnalyticsViewModelTests.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer
import Combine

@Suite(.serialized)
@MainActor
struct RewardAnalyticsViewModelTests {
	let viewModel: RewardAnalyticsViewModel
	let useCase: MockMeUseCase
	let devices: [DeviceDetails]

	init() {
		devices = [DeviceDetails.mockDevice]
		useCase = MockMeUseCase()
		viewModel = RewardAnalyticsViewModel(useCase: useCase, devices: devices)
	}

	@Test func initialization() async throws {
		#expect(viewModel.devices.count == devices.count)
		#expect(viewModel.state == .content)
		#expect(viewModel.summaryMode == .week)
		#expect(viewModel.totalEearnedText == "\(53.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")

		let actualReward = try #require(DeviceDetails.mockDevice.rewards?.actualReward)
		#expect(viewModel.lastRunValueText == "+\(actualReward.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")

		try await Task.sleep(for: .seconds(1))
		#expect(!viewModel.suammaryRewardsIsLoading)
		#expect(viewModel.summaryEarnedValueText == "\(0.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)")
		#expect(viewModel.summaryChartDataItems?.isEmpty == true)
	}

	@Test func handleDeviceTap() async throws {
		let device = devices.first!
		viewModel.handleDeviceTap(device)
		try await Task.sleep(for: .seconds(1))
		#expect(viewModel.stationItems[device.id!]?.isExpanded == true)
	}

	@Test func testSetMode() {
		let device = devices.first!
		viewModel.setMode(.month, for: device.id!)
		#expect(viewModel.stationItems[device.id!]?.mode == .month)
	}
}

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

	@Test func initialization() {
		#expect(viewModel.devices.count == devices.count)
		#expect(viewModel.state == .content)
		#expect(viewModel.summaryMode == .week)
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

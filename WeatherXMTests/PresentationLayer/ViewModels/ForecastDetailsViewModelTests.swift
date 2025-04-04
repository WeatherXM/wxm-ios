//
//  ForecastDetailsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 4/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@MainActor
struct ForecastDetailsViewModelTests {
	let viewModel: ForecastDetailsViewModel
	let device: DeviceDetails
	let forecasts: [NetworkDeviceForecastResponse]
	let followState: UserDeviceFollowState?

	init() {
		device = DeviceDetails.mockDevice
		forecasts = [.init(tz: "",
						   date: Date.now.toTimestamp(),
						   hourly: [.mockInstance])]
		followState = nil
		viewModel = .init(configuration: .init(forecasts: forecasts, selectedforecastIndex: 0, selectedHour: nil, device: device, followState: followState))
	}

	@Test func testInitialization() {
		#expect(viewModel.device.id == device.id)
		#expect(viewModel.forecasts.count == forecasts.count)
		#expect(viewModel.navigationTitle == device.displayName)
		#expect(viewModel.navigationSubtitle == (device.friendlyName.isNilOrEmpty ? nil : device.name))
		#expect(viewModel.selectedForecastIndex == 0)
		#expect(viewModel.currentForecast?.tz == forecasts.first?.tz)
	}
}

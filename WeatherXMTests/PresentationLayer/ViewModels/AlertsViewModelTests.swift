//
//  AlertsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@Suite(.serialized)
@MainActor
struct AlertsViewModelTests {

    @Test func withNoErrors() async throws {
		let device = DeviceDetails(name: "Test Device", isActive: true)
		let viewModel = AlertsViewModel(device: device, mainVM: .shared, followState: nil)
		#expect(viewModel.alerts.isEmpty)
    }

	@Test func withErrorsNotOwned() {
		let device = DeviceDetails(name: "Test Device", batteryState: .low, isActive: false)
		let viewModel = AlertsViewModel(device: device, mainVM: .shared, followState: nil)
		#expect(viewModel.alerts.count == 1)
	}

	@Test func withErrorsOwned() {
		let device = DeviceDetails(id: "124",
								   name: "Test Device",
								   batteryState: .low,
								   isActive: false)
		let followState = UserDeviceFollowState(deviceId: "124", relation: .owned)
		let viewModel = AlertsViewModel(device: device, mainVM: .shared, followState: followState)
		#expect(viewModel.alerts.count == 2)
	}
}

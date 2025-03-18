//
//  BTActionWrapperTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 18/3/25.
//

import Testing
@testable import DataLayer
import DomainLayer
import Toolkit

@Suite(.serialized)
struct BTActionWrapperTests {

	let actionsWrapper: BTActionWrapper

	init() {
		actionsWrapper = BTActionWrapper()
	}

	@Test func connectNormal() async throws {
		try await simulateNormal()
		let deviceDetails = DeviceDetails(name: "WXMDevice",
										  label: "WXMDevice",
										  isActive: true)

		let error = await actionsWrapper.connect(device: deviceDetails)
		#expect(error == nil)
    }

	@Test func connectInvalid() async throws {
		try await simulateNormal()
		let deviceDetails = DeviceDetails(name: "NoWXM",
										  label: "NoWXM",
										  isActive: true)

		let error = await actionsWrapper.connect(device: deviceDetails)
		#expect(error == .notInRange)
	}

	@Test func notConnectable() async throws {
		try await simulateNotConnectable()
		let deviceDetails = DeviceDetails(name: "WXMDevice",
										  label: "WXMDevice",
										  isActive: true)

		let error = await actionsWrapper.connect(device: deviceDetails)
		#expect(error == .connect)
	}
}

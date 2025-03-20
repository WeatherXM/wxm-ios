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

	@Test func rebootNormal() async throws {
		try await simulateNormal()
		let deviceDetails = DeviceDetails(name: "WXMDevice",
										  label: "WXMDevice",
										  isActive: true)

		let error = await actionsWrapper.reboot(device: deviceDetails)
		#expect(error == nil)
	}

	@Test func rebootInvalid() async throws {
		try await simulateNormal()
		let deviceDetails = DeviceDetails(name: "NoWXM",
										  label: "NoWXM",
										  isActive: true)

		let error = await actionsWrapper.reboot(device: deviceDetails)
		#expect(error == .notInRange)
	}

	@Test func rebootNotConnectable() async throws {
		try await simulateNotConnectable()
		let deviceDetails = DeviceDetails(name: "WXMDevice",
										  label: "WXMDevice",
										  isActive: true)

		let error = await actionsWrapper.reboot(device: deviceDetails, connectRetries: 0)
		#expect(error == .reboot)
	}

	@Test func setFrequencyNormal() async throws {
		try await simulateNormal()
		let deviceDetails = DeviceDetails(name: "WXMDevice",
										  label: "WXMDevice",
										  isActive: true)

		let error = await actionsWrapper.setFrequency(device: deviceDetails, frequency: .AS923_1B)
		#expect(error == nil)
	}

	@Test func setFrequencyInvalid() async throws {
		try await simulateNormal()
		let deviceDetails = DeviceDetails(name: "NoWXM",
										  label: "NoWXM",
										  isActive: true)

		let error = await actionsWrapper.setFrequency(device: deviceDetails, frequency: .AS923_1B)
		#expect(error == .notInRange)
	}

	@Test func setFrequencyNotConnectable() async throws {
		try await simulateNotConnectable()
		let deviceDetails = DeviceDetails(name: "WXMDevice",
										  label: "WXMDevice",
										  isActive: true)

		let error = await actionsWrapper.setFrequency(device: deviceDetails,
													  frequency: .AS923_1B,
													  connectRetries: 0)
		#expect(error == .connect)
	}

	@Test func getDevEUINormal() async throws {
		try await simulateNormal()
		let deviceDetails = DeviceDetails(name: "WXMDevice",
										  label: "WXMDevice",
										  isActive: true)

		let value = await actionsWrapper.getDevEUI(deviceDetails)
		let devEui = try #require(value.value)
		#expect(value.error == nil)
		#expect(devEui == "123")
	}

}

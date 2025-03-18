//
//  BluetoothManagerTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 17/3/25.
//

import Testing
@testable import DataLayer
import Toolkit
import Combine
import CoreBluetoothMock

struct BluetoothManagerTests {
	let manager: BluetoothManager
	let cancellableWrapper = CancellableWrapper()

	init() {
		self.manager = .init()
	}

    @Test func connectDisconnect() async throws {
		try await simulateNormal()
		manager.enable()
		return try await confirmation { confirm in
			manager.state.flatMap { state in
				#expect(state == .poweredOn)
				manager.startScanning()

				return manager.devices
			}.dropFirst().flatMap { devices in
				#expect(!devices.isEmpty)
				let device = devices.first!
				return Just(device)
			}.sink { device in
				manager.connect(to: device) { error in
					#expect(error == nil)
					let cbPeripheral = manager._devices.first?.cbPeripheral
					#expect(cbPeripheral?.state == .connected)
					manager.disconnect(from: device)
					#expect(cbPeripheral?.state != .connected)
					confirm()
				}
			}.store(in: &cancellableWrapper.cancellableSet)

			try await Task.sleep(for: .seconds(5))
		}
    }
}

private extension BluetoothManagerTests {
	func simulateNormal() async  throws{
		CBMCentralManagerMock.simulateInitialState(.poweredOn)
		CBMCentralManagerMock.simulatePeripherals([mockHelium])
		try await Task.sleep(for: .seconds(1))
	}

	func simulatPoweredOff() async throws {
		CBMCentralManagerMock.simulateInitialState(.poweredOff)
		try await Task.sleep(for: .seconds(1))
	}
}

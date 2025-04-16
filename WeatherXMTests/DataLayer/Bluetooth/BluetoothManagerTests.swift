//
//  BluetoothManagerTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 17/3/25.
//

import Testing
@testable import DataLayer
import DomainLayer
import Toolkit
import Combine
import CoreBluetoothMock

@Suite(.serialized)
struct BluetoothManagerTests {
	let manager: BluetoothManager
	let cancellableWrapper = CancellableWrapper()

	init() {
		self.manager = .init()
		print("Initialized")
	}

    @Test func connectDisconnect() async throws {
		try await simulateNormal()
		manager.enable()
		return try await confirmation { [weak manager] confirm in
			guard let manager else {
				fatalError("Manager is nil")
			}
			
			manager.state.flatMap { state in
				#expect(state == .poweredOn)
				manager.startScanning()

				return manager.devices
			}.dropFirst().flatMap { devices in
				#expect(devices.count == 1)
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

			try await Task.sleep(for: .seconds(7))
		}
    }

	@Test func poweredOff() async throws {
		try await simulatePoweredOff()
		manager.enable()
		return await confirmation { [weak manager] confirm in
			guard let manager else {
				fatalError("Manager is nil")
			}

			manager.state.drop(while: { $0 != .poweredOff }).flatMap { state in
				#expect(state == .poweredOff)
				manager.startScanning()

				return manager.devices
			}.sink { devices in
				#expect(devices.isEmpty)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func connectToInvalidDevice() async throws {
		try await simulateNormal()
		manager.enable()
		return try await confirmation { [weak manager] confirm in
			guard let manager else {
				fatalError("Manager is nil")
			}

			manager.state.flatMap { state in
				#expect(state == .poweredOn)
				manager.startScanning()

				return manager.devices
			}.dropFirst().flatMap { devices in
				#expect(!devices.isEmpty)
				return Just(true)
			}.sink { _ in
				let device = BTWXMDevice(identifier: .init(),
										 state: .connected,
										 name: "TEST",
										 rssi: 1.2,
										 eui: "TEST")
				manager.connect(to: device) { error in
					#expect(error == .peripheralNotFound)
					confirm()
				}
			}.store(in: &cancellableWrapper.cancellableSet)

			try await Task.sleep(for: .seconds(2))
		}
	}

	@Test func noWXMDevice() async throws {
		try await simulateNoWXMDevice()
		manager.enable()
		return await confirmation { [weak manager] confirm in
			guard let manager else {
				fatalError("Manager is nil")
			}

			manager.state.drop(while: { $0 != .poweredOn }).flatMap { state in
				#expect(state == .poweredOn)
				manager.startScanning()

				return manager.devices
			}.flatMap { devices in
				#expect(devices.isEmpty)
				return Just(true)
			}.sink { _ in
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

}

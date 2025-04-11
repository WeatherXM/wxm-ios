//
//  BluetoothDevicesRepositoryImplTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 20/3/25.
//

import Testing
@testable import DataLayer
import Toolkit

@Suite(.serialized, .timeLimit(.minutes(3)))
struct BluetoothDevicesRepositoryImplTests {
	let manager: BluetoothManager
	let bluetoothDevicesRepositoryImpl: BluetoothDevicesRepositoryImpl
	var cancellableWrapper: CancellableWrapper = .init()

	init() {
		manager = .init()
		bluetoothDevicesRepositoryImpl = .init(manager: manager)
	}

	@Test func enable() async throws {
		try await simulateNormal()
		try await confirmation { confirm in
			bluetoothDevicesRepositoryImpl.enable()
			bluetoothDevicesRepositoryImpl.state.drop(while: { $0 == .unknown }).prefix(1).sink { state in
				#expect(state == .poweredOn)
				confirm()
			}.store(in: &cancellableWrapper.cancellableSet)
			try await Task.sleep(for: .seconds(2))
		}
    }

	@Test func scanAndConnectDisconnect() async throws {
		try await simulateNormal()

		bluetoothDevicesRepositoryImpl.enable()
		let initialDevices = try await bluetoothDevicesRepositoryImpl.devices.toAsync()
		#expect(initialDevices.isEmpty)

		bluetoothDevicesRepositoryImpl.startScanning()
		let devices = try await bluetoothDevicesRepositoryImpl.devices.dropFirst().eraseToAnyPublisher().toAsync()

		#expect(devices.count == 1)
		let device = try #require(devices.first)
		let error = await bluetoothDevicesRepositoryImpl.connect(device: device)
		#expect(error == nil)
		#expect(manager._devices.first?.cbPeripheral.state == .connected)

		bluetoothDevicesRepositoryImpl.disconnect(device: device)
		try await Task.sleep(for: .seconds(1))
		#expect(manager._devices.first?.cbPeripheral.state == .disconnected)
	}

	@Test func scanAndConnectNotConnectable() async throws {
		try await simulateNotConnectable()

		bluetoothDevicesRepositoryImpl.enable()
		let initialDevices = try await bluetoothDevicesRepositoryImpl.devices.toAsync()
		#expect(initialDevices.isEmpty)

		bluetoothDevicesRepositoryImpl.startScanning()
		let devices = try await bluetoothDevicesRepositoryImpl.devices.dropFirst().eraseToAnyPublisher().toAsync()

		#expect(devices.count == 1)
		let device = try #require(devices.first)
		let error = await bluetoothDevicesRepositoryImpl.connect(device: device)
		#expect(error == .connectionError)
	}


	@Test func fetchDeviceInfo() async throws {
		try await simulateNormal()

		bluetoothDevicesRepositoryImpl.enable()
		let initialDevices = try await bluetoothDevicesRepositoryImpl.devices.toAsync()
		#expect(initialDevices.isEmpty)

		bluetoothDevicesRepositoryImpl.startScanning()
		let devices = try await bluetoothDevicesRepositoryImpl.devices.dropFirst().eraseToAnyPublisher().toAsync()

		#expect(devices.count == 1)
		let device = try #require(devices.first)
		let info = try await bluetoothDevicesRepositoryImpl.fetchDeviceInfo(device).get()
		#expect(info?.devEUI == "123")
		#expect(info?.claimingKey == "123")
	}

	@Test func reboot() async throws {
		try await simulateNormal()

		bluetoothDevicesRepositoryImpl.enable()
		let initialDevices = try await bluetoothDevicesRepositoryImpl.devices.toAsync()
		#expect(initialDevices.isEmpty)

		bluetoothDevicesRepositoryImpl.startScanning()
		let devices = try await bluetoothDevicesRepositoryImpl.devices.drop(while: { $0.isEmpty }).eraseToAnyPublisher().toAsync()

		#expect(devices.count == 1)
		let device = try #require(devices.first)
		let error = await bluetoothDevicesRepositoryImpl.rebootDevice(device)
		#expect(error == nil)
		#expect(manager._devices.first?.cbPeripheral.state == .connected)
	}

	@Test func setFrequency() async throws {
		try await simulateNormal()

		bluetoothDevicesRepositoryImpl.enable()
		let initialDevices = try await bluetoothDevicesRepositoryImpl.devices.toAsync()
		#expect(initialDevices.isEmpty)

		bluetoothDevicesRepositoryImpl.startScanning()
		let devices = try await bluetoothDevicesRepositoryImpl.devices.dropFirst().eraseToAnyPublisher().toAsync()

		#expect(devices.count == 1)
		let device = try #require(devices.first)
		let error = await bluetoothDevicesRepositoryImpl.setFrequency(device, frequency: .AS923_1B)
		#expect(error == nil)
		#expect(manager._devices.first?.cbPeripheral.state == .disconnecting)
	}
}

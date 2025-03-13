//
//  MockBluetoothDevicesRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Foundation
@testable import DomainLayer
import Toolkit
import Combine

class MockBluetoothDevicesRepositoryImpl {
	private(set) var isEnabled = false
	private(set) var scanStarted = false
	private(set) var scanStopped = false
	private(set) var connected = false
	private(set) var disconnected = false
	private(set) var rebooted = false
}

extension MockBluetoothDevicesRepositoryImpl: BluetoothDevicesRepository {
	var state: AnyPublisher<BluetoothState, Never> {
		Just(BluetoothState.poweredOff).eraseToAnyPublisher()
	}
	
	var devices: AnyPublisher<[BTWXMDevice], Never> {
		Just([BTWXMDevice(identifier: UUID(),
						  state: .connected,
						  name: nil,
						  rssi: 0.0,
						  eui: nil)]).eraseToAnyPublisher()
	}
	
	func enable() {
		isEnabled = true
	}
	
	func startScanning() {
		scanStarted = true
	}
	
	func stopScanning() {
		scanStopped = true
	}
	
	func fetchDeviceInfo(_ device: BTWXMDevice) async -> Result<BTWXMDeviceInfo?, BluetoothHeliumError> {
		.success(BTWXMDeviceInfo(devEUI: "124", claimingKey: "124"))
	}
	
	func setFrequency(_ device: BTWXMDevice, frequency: Frequency) async -> BluetoothHeliumError? {
		nil
	}
	
	func rebootDevice(_ device: BTWXMDevice) async -> BluetoothHeliumError? {
		rebooted = true
		return nil
	}
	
	func connect(device: BTWXMDevice) async -> BluetoothHeliumError? {
		connected = true
		return nil
	}
	
	func disconnect(device: BTWXMDevice) {
		disconnected = true
	}
}

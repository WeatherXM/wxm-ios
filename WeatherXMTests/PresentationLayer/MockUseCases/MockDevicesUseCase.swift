//
//  MockDevicesUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/4/25.
//

import Combine
import Foundation
import CoreBluetooth
import DomainLayer

final class MockDevicesUseCase: DevicesUseCaseApi {
	nonisolated(unsafe) var bluetoothEnabled: Bool = false
	nonisolated(unsafe) var scanning: Bool = false
	nonisolated(unsafe) var heliumFrequency: Frequency?
	nonisolated(unsafe) var disconnectCalled: Bool = false
	nonisolated(unsafe) var rebootedDevice: BTWXMDevice?

	var bluetoothState: AnyPublisher<BluetoothState, Never> {
		Just(.poweredOn).eraseToAnyPublisher()
	}

	var bluetoothDevices: AnyPublisher<[BTWXMDevice], Never> {
		Just([BTWXMDevice(identifier: .init(),
						  state: .connected,
						  name: nil,
						  rssi: 0.0,
						  eui: nil)]).eraseToAnyPublisher()
	}

	func enableBluetooth() {
		bluetoothEnabled = true
	}

	func startBluetoothScanning() {
		scanning = true
	}

	func stopBluetoothScanning() {
		scanning = false
	}

	func setHeliumFrequency(_ device: BTWXMDevice, frequency: Frequency) async -> BluetoothHeliumError? {
		heliumFrequency = frequency
		return nil
	}

	func isHeliumDeviceDevEUIValid(_ devEUI: String) -> Bool {
		return true
	}

	func connect(device: BTWXMDevice) async -> BluetoothHeliumError? {
		return nil
	}

	func disconnect(device: BTWXMDevice) {
		disconnectCalled = true
	}

	func reboot(device: BTWXMDevice) async -> BluetoothHeliumError? {
		rebootedDevice = device
		return nil
	}

	func getDeviceInfo(device: BTWXMDevice) async -> Result<BTWXMDeviceInfo?, BluetoothHeliumError> {
		return .success(BTWXMDeviceInfo(devEUI: "mockDevEUI", claimingKey: "mockClaimingKey"))
	}
}

//
//  DevicesUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Combine
import Foundation
import CoreBluetooth

public protocol DevicesUseCaseApi: Sendable {
	var bluetoothState: AnyPublisher<BluetoothState, Never> { get }
	var bluetoothDevices: AnyPublisher<[BTWXMDevice], Never> { get }

	func enableBluetooth()
	func startBluetoothScanning()
	func stopBluetoothScanning()
	func setHeliumFrequency(_ device: BTWXMDevice, frequency: Frequency) async -> BluetoothHeliumError?
	func isHeliumDeviceDevEUIValid(_ devEUI: String) -> Bool
	func connect(device: BTWXMDevice) async -> BluetoothHeliumError?
	func disconnect(device: BTWXMDevice)
	func reboot(device: BTWXMDevice) async -> BluetoothHeliumError?
	func getDeviceInfo(device: BTWXMDevice) async -> Result<BTWXMDeviceInfo?, BluetoothHeliumError>
}

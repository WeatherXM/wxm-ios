//
//  UpdateFirmwareUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Combine
import Foundation

public protocol UpdateFirmwareUseCaseApi: Sendable {
	var bluetoothState: AnyPublisher<BluetoothState, Never> { get }
	var bluetoothDevices: AnyPublisher<[BTWXMDevice], Never> { get }

	func enableBluetooth()
	func startBluetoothScanning()
	func stopBluetoothScanning()
	func updateDeviceFirmware(device: BTWXMDevice, firmwareDeviceId: String) -> AnyPublisher<FirmwareUpdateState, Never>?
	func stopDeviceFirmwareUpdate()
}

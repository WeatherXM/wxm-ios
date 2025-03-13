//
//  DevicesUseCase.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Alamofire
import Combine
import Foundation

public struct DevicesUseCase: @unchecked Sendable {
    private let devicesRepository: DevicesRepository
    private let bluetoothDevicesRepository: BluetoothDevicesRepository

    private static let DEV_EUI_KEY_LENGTH = 16
    private static let DEV_EUI_REGEX = "^[a-fA-F0-9]{16}$"

    public init(
        devicesRepository: DevicesRepository,
        bluetoothDevicesRepository: BluetoothDevicesRepository
    ) {
        self.devicesRepository = devicesRepository
        self.bluetoothDevicesRepository = bluetoothDevicesRepository
        bluetoothState = bluetoothDevicesRepository.state
        bluetoothDevices = bluetoothDevicesRepository.devices
    }

    public let bluetoothState: AnyPublisher<BluetoothState, Never>
    public let bluetoothDevices: AnyPublisher<[BTWXMDevice], Never>

    /**
     As soon as this is called, Bluetooth permission will be requested from the user.
     */
    public func enableBluetooth() {
        bluetoothDevicesRepository.enable()
    }

    public func startBluetoothScanning() {
        bluetoothDevicesRepository.startScanning()
    }

    public func stopBluetoothScanning() {
        bluetoothDevicesRepository.stopScanning()
    }

	public func setHeliumFrequency(_ device: BTWXMDevice, frequency: Frequency) async -> BluetoothHeliumError? {
		await bluetoothDevicesRepository.setFrequency(device, frequency: frequency)
	}

    public func isHeliumDeviceDevEUIValid(_ devEUI: String) -> Bool {
        return devEUI.count == Self.DEV_EUI_KEY_LENGTH && devEUI.matches(Self.DEV_EUI_REGEX)
    }

	public func connect(device: BTWXMDevice) async -> BluetoothHeliumError? {
		await bluetoothDevicesRepository.connect(device: device)
	}

    public func disconnect(device: BTWXMDevice) {
        bluetoothDevicesRepository.disconnect(device: device)
    }

	public func reboot(device: BTWXMDevice) async -> BluetoothHeliumError? {
		await bluetoothDevicesRepository.rebootDevice(device)
	}

	public func getDeviceInfo(device: BTWXMDevice) async -> Result<BTWXMDeviceInfo?, BluetoothHeliumError> {
		let result = await bluetoothDevicesRepository.fetchDeviceInfo(device)
		return result
	}
}

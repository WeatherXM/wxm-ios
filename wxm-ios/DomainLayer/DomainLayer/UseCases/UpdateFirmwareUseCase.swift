//
//  UpdateFirmwareUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 14/2/23.
//

import Combine
import Foundation

public struct UpdateFirmwareUseCase {
    private let firmwareRepository: FirmwareUpdateRepository
    public let bluetoothState: AnyPublisher<BluetoothState, Never>
    public let bluetoothDevices: AnyPublisher<[BTWXMDevice], Never>

    public init(firmwareRepository: FirmwareUpdateRepository) {
        self.firmwareRepository = firmwareRepository
        bluetoothState = firmwareRepository.state
        bluetoothDevices = firmwareRepository.devices
    }

    public func enableBluetooth() {
        firmwareRepository.enableBluetooth()
    }

    public func startBluetoothScanning() {
        firmwareRepository.startScanning()
    }

    public func stopBluetoothScanning() {
        firmwareRepository.stopScanning()
    }

    public func updateDeviceFirmware(device: BTWXMDevice, firmwareDeviceId: String) -> AnyPublisher<FirmwareUpdateState, Never>? {
        let updateFirmware = firmwareRepository.updateFirmware(for: device, deviceId: firmwareDeviceId)
        return updateFirmware
    }

    public func stopDeviceFirmwareUpdate() {
        firmwareRepository.stopFirmwareUpdate()
    }
}

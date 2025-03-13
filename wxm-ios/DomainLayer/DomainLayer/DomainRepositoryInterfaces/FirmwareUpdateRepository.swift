//
//  FirmwareUpdateRepository.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/2/23.
//

import Combine

public protocol FirmwareUpdateRepository {
    var state: AnyPublisher<BluetoothState, Never> { get }
    var devices: AnyPublisher<[BTWXMDevice], Never> { get }

    func enableBluetooth()
    func startScanning()
    func stopScanning()
    func updateFirmware(for device: BTWXMDevice, deviceId: String) -> AnyPublisher<FirmwareUpdateState, Never>
    func stopFirmwareUpdate()
}

public enum FirmwareUpdateState: Equatable {
    case unknown
    case connecting
    case downloading
    case installing(progress: Int)
    case finished
    case error(FirmwareUpdateError)
}

public enum FirmwareUpdateError: Error, Equatable {
    case downloadFile
    case connection
    case installation(String?)
}

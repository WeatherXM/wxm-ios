//
//  MockFirmwareUpdateRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Foundation
@testable import DomainLayer
import Combine

class MockFirmwareUpdateRepositoryImpl {
	private(set) var isBluetoothEnabled = false
	private(set) var scanStarted = false
	private(set) var scanStopped = false
	private(set) var firmwareUpdateStopped = false
	private let stateSubject = CurrentValueSubject<FirmwareUpdateState, Never>(.unknown)
	private let btStateSubject = CurrentValueSubject<BluetoothState, Never>(.unknown)
	private let devicesSubject = CurrentValueSubject<[BTWXMDevice], Never>([])


}

extension MockFirmwareUpdateRepositoryImpl: FirmwareUpdateRepository {
	var state: AnyPublisher<BluetoothState, Never> {
		btStateSubject.eraseToAnyPublisher()
	}
	
	var devices: AnyPublisher<[BTWXMDevice], Never> {
		devicesSubject.eraseToAnyPublisher()
	}
	
	func enableBluetooth() {
		isBluetoothEnabled = true
	}
	
	func startScanning() {
		scanStarted = true
	}
	
	func stopScanning() {
		scanStopped = true
	}
	
	func updateFirmware(for device: BTWXMDevice, deviceId: String) -> AnyPublisher<FirmwareUpdateState, Never> {
		stateSubject.eraseToAnyPublisher()
	}
	
	func stopFirmwareUpdate() {
		firmwareUpdateStopped = true
	}
}

//
//  UpdateFirmwareUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Testing
@testable import DomainLayer
import Combine
import Toolkit

struct UpdateFirmwareUseCaseTests {
	let repository: MockFirmwareUpdateRepositoryImpl = .init()
	let useCase: UpdateFirmwareUseCase
	let cancellableWrapper: CancellableWrapper = .init()

	init() {
		self.useCase = .init(firmwareRepository: repository)
	}

    @Test func enableBluetooth() {
		#expect(!repository.isBluetoothEnabled)
		useCase.enableBluetooth()
		#expect(repository.isBluetoothEnabled)
    }

	@Test func startScanning() {
		#expect(!repository.scanStarted)
		useCase.startBluetoothScanning()
		#expect(repository.scanStarted)
	}

	@Test func stopScanning() {
		#expect(!repository.scanStopped)
		useCase.stopBluetoothScanning()
		#expect(repository.scanStopped)
	}

	@Test func updateFirmware() async throws {
		return await confirmation { confim in
			let device = BTWXMDevice(identifier: .init(),
									 state: .connected,
									 name: nil, rssi: 10.0,
									 eui: nil)
			useCase.updateDeviceFirmware(device: device,
										 firmwareDeviceId: "124")?.sink { state in
				#expect(state == .unknown)
				confim()
			}.store(in: &cancellableWrapper.cancellableSet)
		}
	}

	@Test func stopUpdateFirmware() {
		#expect(!repository.firmwareUpdateStopped)
		useCase.stopDeviceFirmwareUpdate()
		#expect(repository.firmwareUpdateStopped)
	}
}

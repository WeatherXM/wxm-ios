//
//  DevicesUseCaseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Testing
@testable import DomainLayer

struct DevicesUseCaseTests {
	private let testDevice = BTWXMDevice(identifier: UUID(),
										 state: .connected,
										 name: nil,
										 rssi: 0.0,
										 eui: nil)
	let btRepository: MockBluetoothDevicesRepositoryImpl = .init()
	let devicesRepository: MockDevicesRepositoryImpl = .init()
	let useCase: DevicesUseCase

	init() {
		self.useCase = .init(devicesRepository: devicesRepository, bluetoothDevicesRepository: btRepository)
	}

    @Test func enableBluetooth() async throws {
		#expect(!btRepository.isEnabled)
		useCase.enableBluetooth()
		#expect(btRepository.isEnabled)
    }

	@Test func startBluetoothScanning() {
		#expect(!btRepository.scanStarted)
		useCase.startBluetoothScanning()
		#expect(btRepository.scanStarted)
	}

	@Test func stopBluetoothScanning() {
		#expect(!btRepository.scanStopped)
		useCase.stopBluetoothScanning()
		#expect(btRepository.scanStopped)
	}

	@Test func setHeliumFrequency() async {
		let error = await useCase.setHeliumFrequency(testDevice, frequency: .AS923_1)
		#expect(error == nil)
	}

	@Test func isHeliumDeviceDevEUIValid() async {
		var invalid = "122"
		#expect(!useCase.isHeliumDeviceDevEUIValid(invalid))

		invalid = "1234h67890123456"
		#expect(!useCase.isHeliumDeviceDevEUIValid(invalid))

		let valid = "fFffffffffffffff"
		#expect(useCase.isHeliumDeviceDevEUIValid(valid))
	}

	@Test func connect() async {
		#expect(!btRepository.connected)

		let error = await useCase.connect(device: testDevice)
		#expect(error == nil)

		#expect(btRepository.connected)
	}

	@Test func disConnect() async {
		#expect(!btRepository.disconnected)
		useCase.disconnect(device: testDevice)
		#expect(btRepository.disconnected)
	}

	@Test func reboot() async {
		#expect(!btRepository.rebooted)

		let error = await useCase.reboot(device: testDevice)
		#expect(error == nil)

		#expect(btRepository.rebooted)
	}
}

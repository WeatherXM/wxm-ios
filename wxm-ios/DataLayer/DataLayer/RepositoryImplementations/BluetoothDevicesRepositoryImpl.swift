//
//  BluetoothDevicesRepositoryImpl.swift
//  DataLayer
//
//  Created by Manolis Katsifarakis on 27/9/22.
//

import Combine
import CoreBluetooth
import DomainLayer

public class BluetoothDevicesRepositoryImpl: NSObject, BluetoothDevicesRepository {

    public let state: AnyPublisher<BluetoothState, Never>
    public let devices: AnyPublisher<[BTWXMDevice], Never>

    private var cancellableSet: Set<AnyCancellable> = []

    private let manager: BluetoothManager
	private let bluetoothWrapper: BTActionWrapper

    private var prepareDeviceCallback: (() -> Void)?

    override public init() {
        manager = BluetoothManager()
        state = manager.state
        devices = manager.devices
		bluetoothWrapper = .init(bluetoothManager: manager)
    }

    /**
     As soon as the repository is enabled, Bluetooth permission will be requested from the user.
     */
    public func enable() {
        manager.enable()
    }

    public func startScanning() {
        manager.startScanning()
    }

    public func stopScanning() {
        manager.stopScanning()
    }

	public func fetchDeviceInfo(_ device: BTWXMDevice) async -> Result<BTWXMDeviceInfo?, BluetoothHeliumError> {
		let devEUI = await bluetoothWrapper.getDevEUI(device)
		if let error = devEUI.error {
			return .failure(error.toBluetoothError)
		}

		let devEUIValue = devEUI.value

		let claimingKey = await bluetoothWrapper.getClaimingKey(device)
		if let error = claimingKey.error {
			return .failure(error.toBluetoothError)
		}

		let claimingKeyValue = claimingKey.value

		return .success(BTWXMDeviceInfo(devEUI: devEUIValue ?? "",
										claimingKey: claimingKeyValue ?? ""))
	}

	public func rebootDevice(_ device: BTWXMDevice) async -> BluetoothHeliumError? {
		await bluetoothWrapper.rebootDevice(device, keepConnected: true)?.toBluetoothError
	}

	public func connect(device: BTWXMDevice) async -> BluetoothHeliumError? {
		await withUnsafeContinuation { continuation in
			manager.connect(to: device) { error in
				continuation.resume(returning: error?.toDomainBluetoothHeliumError)
			}
		}
	}

    public func disconnect(device: BTWXMDevice) {
        manager.disconnect(from: device)
    }

	public func setFrequency(_ device: BTWXMDevice, frequency: Frequency) async -> BluetoothHeliumError? {
		await bluetoothWrapper.setDeviceFrequency(device, frequency: frequency)?.toBluetoothError
	}
}

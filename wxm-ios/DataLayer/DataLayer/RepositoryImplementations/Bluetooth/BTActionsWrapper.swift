//
//  BTActionsWrapper.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 10/3/23.
//

import Foundation
import Combine
import DomainLayer

/// Wraps the bluetooth actions such as connect to station, reboot, set frequency etc.
/// The goal is to encapsulate the apple's API with delegation pattern and expose async functions
class BTActionWrapper {
    private lazy var bluetoothManager: BluetoothManager = BluetoothManager()
    private var cancellables: Set<AnyCancellable> = []
    private var scanningTimeoutWorkItem: DispatchWorkItem?
    private var rebootStationWorkItem: DispatchWorkItem?
    private var performCommandDelegate: BTPerformCommandDelegate?

    /// Connect to a the passed device. Scans to find the corresponding ΒΤ device and connects to it
    /// - Parameter device: The device to connect
    /// - Returns: The error of the process, nil if is successful
    func connect(device: DeviceDetails) async -> ActionError? {
        if let btStateError = await observeBTState(for: device) {
            return btStateError
        }

        do {
            if let btDevice = try await findBTDevice(device: device) {
                return await withCheckedContinuation { [weak self] continuation in
                    self?.connectToDevice(btDevice, retries: 0) { error in
                        continuation.resume(returning: error)
                    }
                }
            }
        } catch let error as ActionError {
            return error
        } catch {
            print(error)
        }

        return .unknown
    }

    /// Reboots to a the passed device. Scans to find the corresponding ΒΤ device and reboots
    /// - Parameter device: The device to reboot
    /// - Returns: The error of the process, nil if is successful
    func reboot(device: DeviceDetails) async -> ActionError? {
        if let btStateError = await observeBTState(for: device) {
            return btStateError
        }

        do {
            if let btDevice = try await findBTDevice(device: device) {
                return await rebootDevice(btDevice)
            }
        } catch let error as ActionError {
            return error
        } catch {
            print(error)
        }

        return .unknown
    }

    /// Changes the station's frequency. Scans to find the corresponding ΒΤ device and performs the AT command
    /// - Parameters:
    ///   - device: The device to set frequency
    ///   - frequency: The new frequency
    /// - Returns: The error of the process, nil if is successful
    func setFrequency(device: DeviceDetails, frequency: Frequency) async -> ActionError? {
        if let btStateError = await observeBTState(for: device) {
            return btStateError
        }

        do {
            if let btDevice = try await findBTDevice(device: device) {
                return await setDeviceFrequency(btDevice, frequency: frequency)
            }
        } catch let error as ActionError {
            return error
        } catch {
            print(error)
        }

        return .unknown
    }

	func setDeviceFrequency(_ device: BTWXMDevice, frequency: Frequency) async -> ActionError? {
		guard let deviceWithCBPeripheral = bluetoothManager._devices.first(where: { $0.wxmDevice == device }) else {
			return .setFrequency(nil)
		}

		return await withCheckedContinuation { continuation in
			let command = String(format: BTCommands.AT_SET_FREQUENCY_COMMAND_FORMAT, "\(frequency.heliumBand)")
			let delegate = BTPerformCommandDelegate(peripheral: deviceWithCBPeripheral.cbPeripheral)
			delegate?.performCommand(command: command) { [weak self] response, error in
				defer {
					self?.bluetoothManager.disconnect(from: device)
					self?.performCommandDelegate = nil
				}

				guard error == nil, response?.lowercased() == BTCommands.SUCCESS_RESPONSE else {
					continuation.resume(returning: .setFrequency(error))
					return
				}
				continuation.resume(returning: nil)
			}
			performCommandDelegate = delegate
		}
	}
}

private extension BTActionWrapper {
    func observeBTState(for device: DeviceDetails) async -> ActionError? {
        bluetoothManager.enable()

        return await withCheckedContinuation { [weak self] continuation in
            guard let self = self else {
                return
            }
            self.bluetoothManager.state.sink { state in
                switch state {
                    case .unsupported:
                        continuation.resume(returning: .bluetoothState(.unsupported))
                    case .unauthorized:
                        continuation.resume(returning: .bluetoothState(.unauthorized))
                    case .poweredOff:
                        continuation.resume(returning: .bluetoothState(.poweredOff))
                    case .poweredOn, .resetting:
                        continuation.resume(returning: nil)
                    case .unknown:
                        break
                }
            }.store(in: &self.cancellables)
        }
    }

    func findBTDevice(device: DeviceDetails) async throws -> BTWXMDevice? {
        return try await withCheckedThrowingContinuation { [weak self]  continuation in
            guard let self = self else {
                return
            }
            self.startScanning { error in
                if let error {
                    continuation.resume(throwing: error)
                }
            }
            self.bluetoothManager.devices.sink { [weak self] btDevices in
                guard let self = self,
                      let btDevice = btDevices.first(where: { $0.isSame(with: device) }) else {
                    return
                }
                self.stopScanning()
                continuation.resume(returning: btDevice)
            }.store(in: &self.cancellables)
        }
    }

    func startScanning(completion: @escaping (ActionError?) -> Void) {
        scanningTimeoutWorkItem?.cancel()
        bluetoothManager.startScanning()
        scanningTimeoutWorkItem = DispatchWorkItem { [weak self] in
            self?.stopScanning()
            completion(.notInRange)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: scanningTimeoutWorkItem!)
    }

    func stopScanning() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        scanningTimeoutWorkItem?.cancel()
        scanningTimeoutWorkItem = nil
        bluetoothManager.stopScanning()
    }

    func rebootDevice(_ device: BTWXMDevice) async -> ActionError? {
        rebootStationWorkItem?.cancel()
        bluetoothManager.disconnect(from: device)
        return await withCheckedContinuation { [weak self] continuation in
            connectToDevice(device, retries: 5) { error in
                if error != nil {
                    continuation.resume(returning: .reboot)
                    return
                }


                self?.bluetoothManager.disconnect(from: device)
                continuation.resume(returning: nil)
            }
        }
    }

    func connectToDevice(_ device: BTWXMDevice, retries: Int, completion: @escaping (ActionError?) -> Void) {
        let workItem = DispatchWorkItem { [weak self] in
            self?.bluetoothManager.connect(to: device) { error in
                if error == nil {
                    completion(nil)
                    return
                }

                if retries > 0 {
                    self?.connectToDevice(device, retries: retries - 1, completion: completion)
                    return
                }
                completion(.connect)
            }
        }
        rebootStationWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: workItem)
    }
}

extension BTActionWrapper {
    enum ActionError: Error {
        case bluetoothState(BluetoothState)
        case reboot
        case notInRange
        case connect
        case setFrequency(BTPerformCommandDelegate.BTCommandError?)
        case unknown
    }
}


//
//  BTActionsWrapper.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 10/3/23.
//

import Foundation
import Combine
@preconcurrency import DomainLayer

/// Wraps the bluetooth actions such as connect to station, reboot, set frequency etc.
/// The goal is to encapsulate the apple's API with delegation pattern and expose async functions
class BTActionWrapper {
    private let bluetoothManager: BluetoothManager
    private var cancellables: Set<AnyCancellable> = []
    private var scanningTimeoutWorkItem: DispatchWorkItem?
    private var rebootStationWorkItem: DispatchWorkItem?
    private var performCommandDelegate: BTPerformCommandDelegate?

	init(bluetoothManager: BluetoothManager = .init()) {
		self.bluetoothManager = bluetoothManager
	}

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
                return await rebootDevice(btDevice, keepConnected: false)
            }
        } catch let error as ActionError {
            return error
        } catch {
            print(error)
        }

        return .unknown
    }

	func rebootDevice(_ device: BTWXMDevice, keepConnected: Bool) async -> ActionError? {
		rebootStationWorkItem?.cancel()
		bluetoothManager.disconnect(from: device)
		return await withCheckedContinuation { [weak self] continuation in
			self?.connectToDevice(device, retries: 10) { error in
				if error != nil {
					continuation.resume(returning: .reboot)
					return
				}

				if !keepConnected {
					self?.bluetoothManager.disconnect(from: device)
				}

				continuation.resume(returning: nil)
			}
		}
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
			self.connectToDevice(device, retries: 5) { [weak self] error in
				guard error == nil else {
					continuation.resume(returning: error)
					return
				}

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
				self?.performCommandDelegate = delegate
			}
		}
	}

	func getDevEUI(_ device: BTWXMDevice) async -> (value: String?, error: ActionError?) {
		return await withUnsafeContinuation { [weak self] continuation in
			self?.connectToDevice(device, retries: 5) { error in
				guard error == nil else {
					continuation.resume(returning: (nil, error))
					return
				}

				self?.fetchDevEUI(device: device) { value, error in
					guard value?.lowercased() != BTCommands.SUCCESS_RESPONSE else {
						return
					}
					continuation.resume(returning: (value, error))
				}
			}
		}
	}

	func getClaimingKey(_ device: BTWXMDevice) async -> (value: String?, error: ActionError?) {
		return await withUnsafeContinuation { [weak self] continuation in
			self?.connectToDevice(device, retries: 5) { error in
				guard error == nil else {
					continuation.resume(returning: (nil, error))
					return
				}
				
				self?.fetchClaimingKey(device: device) { value, error in
					guard value?.lowercased() != BTCommands.SUCCESS_RESPONSE else {
						return
					}

					continuation.resume(returning: (value, error))
				}
			}
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

	func fetchDevEUI(device: BTWXMDevice, completion: @escaping (String?, ActionError?) -> Void) {
		guard let deviceWithCBPeripheral = bluetoothManager._devices.first(where: { $0.wxmDevice == device }) else {
			completion(nil, .fetchDevEUI(nil))
			return
		}

		performCommandDelegate = BTPerformCommandDelegate(peripheral: deviceWithCBPeripheral.cbPeripheral)
		performCommandDelegate?.performCommand(command: BTCommands.AT_DEV_EUI_COMMAND) { response, error in
			if let error {
				completion(nil, .fetchDevEUI(error))
				return
			}

			completion(response, nil)
		}
	}

	func fetchClaimingKey(device: BTWXMDevice, completion: @escaping (String?, ActionError?) -> Void) {
		guard let deviceWithCBPeripheral = bluetoothManager._devices.first(where: { $0.wxmDevice == device }) else {
			completion(nil, .fetchClaimingKey(nil))
			return
		}

		performCommandDelegate = BTPerformCommandDelegate(peripheral: deviceWithCBPeripheral.cbPeripheral)
		performCommandDelegate?.performCommand(command: BTCommands.AT_CLAIMING_KEY_COMMAND) { response, error in
			if let error {
				completion(nil, .fetchClaimingKey(error))
				return
			}

			completion(response, nil)
		}
	}

//	func fetchClaimingKey() {
//		stateSubject.send(.fetchingClaimingKey)
//		performCommandDelegate?.performCommand(command: BTCommands.AT_CLAIMING_KEY_COMMAND) { [weak self] response, error in
//			if let error {
//				self?.handleError(.readFromCharacteristic(error))
//				return
//			}
//			self?.didFetchValue(response ?? "")
//		}
//	}
}

extension BTActionWrapper {
    enum ActionError: Error {
        case bluetoothState(BluetoothState)
        case reboot
        case notInRange
        case connect
        case setFrequency(BTPerformCommandDelegate.BTCommandError?)
		case fetchDevEUI(BTPerformCommandDelegate.BTCommandError?)
		case fetchClaimingKey(BTPerformCommandDelegate.BTCommandError?)
        case unknown
    }
}

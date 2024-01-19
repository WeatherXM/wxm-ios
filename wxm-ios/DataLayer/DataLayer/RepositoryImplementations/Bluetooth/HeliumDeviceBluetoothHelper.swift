//
//  HeliumDeviceBluetoothHelper.swift
//  DataLayer
//
//  Created by Manolis Katsifarakis on 20/11/22.
//

import Combine
import CoreBluetooth
import DomainLayer

class HeliumDeviceBluetoothHelper: NSObject {
    let device: WXMDeviceWithCBPeripheral
    let state: AnyPublisher<HelperState, Never>

    enum HelperState {
        case idle
        case discoveringCharacteristics
        case fetchingDevEUI
        case fetchingClaimingKey
        case fetchInfoSuccess(HeliumDevice)
        case settingFrequency
        case frequencySetSuccess
        case frequencySetError
        case error(HeliumDeviceError)
    }

    enum HeliumDeviceError {
        case serviceDiscovery(Error)
        case characteristicDiscovery(Error)
        case writeToCharacteristic(Error)
        case readFromCharacteristic(Error)
        case readValueInvalid
        case illegalStateEncountered
    }

    private var stateSubject = CurrentValueSubject<HelperState, Never>(.idle)
    private var devEUI: String?
    private var claimingKey: String?
    private var performCommandDelegate: BTPerformCommandDelegate?

    init(device: WXMDeviceWithCBPeripheral) {
        self.device = device
        state = stateSubject.eraseToAnyPublisher()
    }

    func fetchDeviceInformation() {
        fetchDevEUI()
    }

    func setFrequency(_ frequency: Frequency) {
        if case .idle = stateSubject.value {
            stateSubject.send(.settingFrequency)
            let frequencyCommand = String(format: BTCommands.AT_SET_FREQUENCY_COMMAND_FORMAT, "\(frequency.heliumBand)")
            performCommandDelegate = BTPerformCommandDelegate(peripheral: device.cbPeripheral)
            performCommandDelegate?.performCommand(command: frequencyCommand) { [weak self] response, error in
                if error != nil {
                    self?.stateSubject.send(.frequencySetError)
                    return
                }
                self?.didFetchValue(response ?? "")
            }

            return
        }

        stateSubject.send(.frequencySetError)
        stateSubject.send(.idle)
        print("Could not set frequency. Device is in an invalid state (\(stateSubject.value)).")
    }
}

private extension HeliumDeviceBluetoothHelper {
    func fetchDevEUI() {
        stateSubject.send(.fetchingDevEUI)
        performCommandDelegate = BTPerformCommandDelegate(peripheral: device.cbPeripheral)
        performCommandDelegate?.performCommand(command: BTCommands.AT_DEV_EUI_COMMAND) { [weak self] response, error in
            if let error {
                self?.handleError(.readFromCharacteristic(error))
                return
            }
            self?.didFetchValue(response ?? "")
        }
    }

    func fetchClaimingKey() {
        stateSubject.send(.fetchingClaimingKey)
        performCommandDelegate?.performCommand(command: BTCommands.AT_CLAIMING_KEY_COMMAND) { [weak self] response, error in
            if let error {
                self?.handleError(.readFromCharacteristic(error))
                return
            }
            self?.didFetchValue(response ?? "")
        }
    }

    func didFetchValue(_ value: String) {
        switch stateSubject.value {
        case .fetchingDevEUI:
            if value.lowercased() == BTCommands.SUCCESS_RESPONSE {
                return
            }
            devEUI = value
            fetchClaimingKey()
        case .fetchingClaimingKey:
            if value.lowercased() == BTCommands.SUCCESS_RESPONSE {
                return
            }
            claimingKey = value
            if
                let devEUI = devEUI,
                let claimingKey = claimingKey
            {
                stateSubject.send(
                    .fetchInfoSuccess(
                        HeliumDevice(devEUI: devEUI, deviceKey: claimingKey)
                    )
                )

                stateSubject.send(.idle)
            } else {
                handleError(.illegalStateEncountered)
            }
            performCommandDelegate = nil
        case .settingFrequency:
            guard value.lowercased() == BTCommands.SUCCESS_RESPONSE else {
                stateSubject.send(.frequencySetError)
                return
            }
            stateSubject.send(.frequencySetSuccess)
            stateSubject.send(.idle)
            performCommandDelegate = nil

        default:
            break
        }
    }

    func handleError(_ error: HeliumDeviceError) {
        if case .settingFrequency = stateSubject.value {
            stateSubject.send(.frequencySetError)
            print("HeliumDeviceBluetoothHelper setting frequency error: \(error)")
        } else {
            stateSubject.send(.error(error))
            print("HeliumDeviceBluetoothHelper error: \(error)")
        }
        performCommandDelegate = nil
        stateSubject.send(.idle)
    }
}

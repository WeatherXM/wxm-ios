//
//  BTWriteCommandDelegate.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 10/2/23.
//

import CoreBluetooth
import Foundation

/// Use this class to encapsulate writting command process.
/// Should keep a ref once is initialized to prevent deallocation untit the command execution is finished.
class BTPerformCommandDelegate: NSObject {
    typealias PerformCommandCallback = (String?, BTCommandError?) -> Void

    private let timeoutInterval: TimeInterval = 10.0
    private let peripheral: CBPeripheral
    private weak var readCharacteristic: CBCharacteristic? {
        didSet {
            performCommandIfIsReady()
        }
    }

    private weak var writeCharacteristic: CBCharacteristic? {
        didSet {
            performCommandIfIsReady()
        }
    }

    private var currentCommand: String?
    private var performCommandCallback: PerformCommandCallback?

    init?(peripheral: CBPeripheral) {
        guard peripheral.state == .connected else {
            return nil
        }
        self.peripheral = peripheral
        super.init()
    }

    /// Sends an AT command on the peripheral passed on initialization. It is required the peripheral is connected
    /// - Parameters:
    ///   - command: The command to be executed
    ///   - callback: The response from the device. The first argument is the string sent back from deivice. T
    ///   The second one is the error if exists. If is nil the command is performed successfully
    func performCommand(command: String, callback: @escaping PerformCommandCallback) {
        guard peripheral.state == .connected else {
            callback(nil, .deviceIsNotConnected)
            return
        }

        currentCommand = command
        performCommandCallback = callback
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        performCommandIfIsReady()
    }
}

extension BTPerformCommandDelegate: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            handleError(.serviceDiscovery(error.localizedDescription))
            return
        }

        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics([], for: service)
        }
    }

    func peripheral(_: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error _: Error?) {
        if readCharacteristic == nil,
           let readCharacteristic = service.characteristics?.first(where: {
               $0.uuid.uuidString.contains(BTCommands.READ_CHARACTERISTIC_UUID)
           })
        {
            self.readCharacteristic = readCharacteristic
        }

        if writeCharacteristic == nil,
           let writeCharacteristic = service.characteristics?.first(where: {
               $0.uuid.uuidString.contains(BTCommands.WRITE_CHARACTERISTIC_UUID)
           })
        {
            self.writeCharacteristic = writeCharacteristic
        }
    }

    public func peripheral(_: CBPeripheral, didWriteValueFor _: CBCharacteristic, error: Error?) {
        if let error = error {
            handleError(.writeToCharacteristic(error.localizedDescription))
            return
        }
    }

    public func peripheral(_: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            handleError(.readFromCharacteristic(error.localizedDescription))
            return
        }

        handleReceivedValue(characteristic.value)
    }
}

private extension BTPerformCommandDelegate {
    /// Called every time the characteristis are set and
    /// if everything is configured correctly we proceed to the command execution
    func performCommandIfIsReady() {
        guard let readCharacteristic,
              let writeCharacteristic,
              let currentCommand
        else {
            return
        }
        peripheral.setNotifyValue(true, for: readCharacteristic)
        peripheral.writeValue(
            currentCommand.data(using: .utf8)!,
            for: writeCharacteristic,
            type: .withResponse
        )
    }

    func handleError(_ error: BTCommandError) {
        performCommandCallback?(nil, error)
    }

    func handleReceivedValue(_ valueData: Data?) {
        guard let valueString = valueData?.convertedCharacteristicValue()
        else {
            handleError(.readValueInvalid)
            return
        }

        performCommandCallback?(valueString, nil)
    }
}

extension BTPerformCommandDelegate {
    enum BTCommandError: Error {
        case writeToCharacteristic(String?)
        case readFromCharacteristic(String?)
        case serviceDiscovery(String?)
        case readValueInvalid
        case deviceIsNotConnected
        case timeout

        var errorCode: Int {
            switch self {
                case .writeToCharacteristic:
                    return 0
                case .readFromCharacteristic:
                    return 1
                case .serviceDiscovery:
                    return 2
                case .readValueInvalid:
                    return 3
                case .deviceIsNotConnected:
                    return 4
                case .timeout:
                    return 5
            }
        }
    }
}

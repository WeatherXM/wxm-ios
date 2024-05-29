//
//  BluetoothManager.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 10/2/23.
//

import Combine
import CoreBluetooth
import DomainLayer
import Foundation

class WXMDeviceWithCBPeripheral {
    let wxmDevice: BTWXMDevice
    let cbPeripheral: CBPeripheral

    init(wxmDevice: BTWXMDevice, cbPeripheral: CBPeripheral) {
        self.wxmDevice = wxmDevice
        self.cbPeripheral = cbPeripheral
    }
}

class BluetoothManager: NSObject {
    typealias ConnectCallback = (BTManagerEror?) -> Void
    /// Use this timeout to wait for the `connect` to return.
    /// By design `CBCentralManager` `connect` request doesn't have a timeout
    private let connectionTimeout: TimeInterval = 10.0
    /// Used to identify the device to be disconnected because of timeout
    private weak var peripheralToConnect: CBPeripheral?
    public let state: AnyPublisher<BluetoothState, Never>
    public let devices: AnyPublisher<[BTWXMDevice], Never>

    private let stateSubject = CurrentValueSubject<BluetoothState, Never>(.unknown)
    private let devicesSubject = CurrentValueSubject<[BTWXMDevice], Never>([])

    private var cancellableSet: Set<AnyCancellable> = []
    private var timeoutWorkItem: DispatchWorkItem?

    private var manager: CBCentralManager!
    private(set) var _devices: [WXMDeviceWithCBPeripheral] = [] {
        didSet {
            devicesSubject.send(_devices.map { $0.wxmDevice })
        }
    }

    private var connectCallback: ConnectCallback?
    private var commandDelegate: BTPerformCommandDelegate?

    override public init() {
        state = stateSubject.eraseToAnyPublisher()
        devices = devicesSubject.eraseToAnyPublisher()
        super.init()
    }

    /**
     As soon as the repository is enabled, Bluetooth permission will be requested from the user.
     */
    public func enable() {
        if manager == nil {
            manager = CBCentralManager(
                delegate: nil,
                queue: nil,
                options: [
                    CBCentralManagerOptionShowPowerAlertKey: false,
                ]
            )
            manager.delegate = self
        }
    }

    /// Starts BT scanning and updates the devices list. Observe the `devices` publisher to get changes
    public func startScanning() {
        enable()
        if manager.isScanning || manager.state != .poweredOn { return }

        manager.scanForPeripherals(withServices: nil, options: nil)
        populatePreviouslyAddedPeripherals()
    }

    /// Stops the scanning for new devices
    public func stopScanning() {
        enable()
        manager.stopScan()
    }

    /// Connects to a specific device via bluetooth.
    /// - Parameters:
    ///   - device: The device to connect
    ///   - callback: Called once the connection process is finihsed. If the error is nil the connection is established successfully
    public func connect(to device: BTWXMDevice, callback: @escaping ConnectCallback) {
        guard let cbPeripheral = _devices.first(where: { $0.wxmDevice == device })?.cbPeripheral else {
            callback(.peripheralNotFound)
            return
        }

        switch cbPeripheral.state {
        case .disconnected, .disconnecting:
            connect(cbPeripheral: cbPeripheral, callback: callback)
        case .connected:
            callback(nil)
        case .connecting:
            break
        @unknown default:
            connect(cbPeripheral: cbPeripheral, callback: callback)
        }
    }

    /// Disconnects the device
    /// - Parameter device: The device to disconnect
    public func disconnect(from device: BTWXMDevice) {
        guard let cbPeripheral = _devices.first(where: { $0.wxmDevice == device })?.cbPeripheral else {
            return
        }
        manager.cancelPeripheralConnection(cbPeripheral)
    }

//	func getWXMDevices() async throws -> [BTWXMDevice] {
//		return try await withCheckedThrowingContinuation { [weak self]  continuation in
//			guard let self = self else {
//				return
//			}
//			self.startScanning { error in
//				if let error {
//					continuation.resume(throwing: error)
//				}
//			}
//			self.bluetoothManager.devices.sink { [weak self] btDevices in
//				guard let self else {
//					return
//				}
//				self.stopScanning()
//				continuation.resume(returning: btDevices)
//			}.store(in: &self.cancellables)
//		}
//	}

}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unsupported:
            stateSubject.send(.unsupported)
        case .unauthorized:
            stateSubject.send(.unauthorized)
        case .poweredOff:
            stateSubject.send(.poweredOff)
        case .poweredOn:
            stateSubject.send(.poweredOn)
        case .resetting:
            stateSubject.send(.resetting)
        case .unknown:
            stateSubject.send(.unknown)
        @unknown default:
            stateSubject.send(.unknown)
        }
    }

    public func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheralToConnect == peripheral else {
            return
        }

        let command = String(format: BTCommands.AT_SET_INTERVAL_COMMAND_FORMAT, 3)
        writeCommand(command, peripheral: peripheral) { [weak self] _, _ in
            self?.commandDelegate = nil
            self?.peripheralToConnect = nil
            self?.connectCallback?(nil)
        }
    }

    func centralManager(_: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error _: Error?) {
        guard peripheralToConnect == peripheral else {
            return
        }
        peripheralToConnect = nil
        connectCallback?(.connectionError)
    }

    public func centralManager(_: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?) {
        guard peripheralToConnect == peripheral else {
            return
        }
        peripheralToConnect = nil
        connectCallback?(.connectionError)
    }

    public func centralManager(_: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for _: CBPeripheral) {
        print(event)
    }

    public func centralManager(_: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        print(peripheral)
    }

    public func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        addNewPeripheral(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
}

private extension BluetoothManager {
    func connect(cbPeripheral: CBPeripheral, callback: @escaping ConnectCallback) {
        timeoutWorkItem?.cancel()
        guard manager.state == .poweredOn else {
            callback(.connectionError)
            return
        }

        // Make sure the peripheral is disconnected before connect.
        // Without this line the flow may stuck.
        manager.cancelPeripheralConnection(cbPeripheral)

        peripheralToConnect = cbPeripheral
        connectCallback = callback
        manager.connect(cbPeripheral)

        let workItem = DispatchWorkItem { [weak self] in
            guard cbPeripheral.state == .connecting else { return }
            self?.manager.cancelPeripheralConnection(cbPeripheral)
        }
        timeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + connectionTimeout, execute: workItem)
    }

    func populatePreviouslyAddedPeripherals() {
        manager
            .retrieveConnectedPeripherals(withServices: [])
            .forEach { [weak self] peripheral in
                self?.addNewPeripheral(peripheral: peripheral, advertisementData: [:], rssi: 0)
            }
    }

    func addNewPeripheral(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        let isAlreadyDiscovered = _devices.contains(where: { $0.wxmDevice.identifier == peripheral.identifier })
        if isAlreadyDiscovered {
            devicesSubject.send(_devices.map { $0.wxmDevice })
            return
        }

        if !peripheral.isWXMDevice() {
            return
        }

        var eui: String?
        if let euiSubstring = (advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data)?
            .hexStringEncoded()
            .dropFirst(4)
        {
            eui = String(euiSubstring)
        }

        let newWxmDevice = BTWXMDevice(cbPeripheral: peripheral, rssi: rssi, eui: eui)
        _devices.append(WXMDeviceWithCBPeripheral(wxmDevice: newWxmDevice, cbPeripheral: peripheral))
    }

    func writeCommand(_ command: String, peripheral: CBPeripheral, completion: @escaping BTPerformCommandDelegate.PerformCommandCallback) {
        let peripheralDelegate = BTPerformCommandDelegate(peripheral: peripheral)
        peripheralDelegate?.performCommand(command: command, callback: completion)
        commandDelegate = peripheralDelegate
    }
}

extension BluetoothManager {
    enum BTManagerEror: Error {
        case peripheralNotFound
        case connectionError
        case writeCommandError(BTPerformCommandDelegate.BTCommandError)
        case writeCommandDeviceNotConnectedError
    }
}

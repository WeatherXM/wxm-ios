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
    public var deviceState: AnyPublisher<DeviceState, Never>

    private let deviceStateSubject = CurrentValueSubject<DeviceState, Never>(.idle)

    private var cancellableSet: Set<AnyCancellable> = []

    private var helper: HeliumDeviceBluetoothHelper?
    private let manager: BluetoothManager
    /// Use this timeout to wait for the `connect` to return.
    /// By design `CBCentralManager` `connect` request doesn't have a timeout
    private let connectionTimeout: TimeInterval = 10.0
    /// Used to identify the device to be disconnected because of timeout
    private weak var timeOutPeripheral: CBPeripheral?
    private var rebootStationWorkItem: DispatchWorkItem?
	private lazy var bluetoothWrapper: BTActionWrapper = BTActionWrapper()


    enum BTError {
        case wxmDeviceNotFound
        case peripheralConnectionError
        case helperNotReady
        case helperError(HeliumDeviceBluetoothHelper.HeliumDeviceError)

        init?(managerError: BluetoothManager.BTManagerEror) {
            switch managerError {
            case .peripheralNotFound:
                self = .wxmDeviceNotFound
            case .connectionError:
                self = .peripheralConnectionError
            case .writeCommandError:
                return nil
            case .writeCommandDeviceNotConnectedError:
                return nil
            }
        }
    }

    private var prepareDeviceCallback: (() -> Void)?

    override public init() {
        manager = BluetoothManager()
        state = manager.state
        devices = manager.devices
        deviceState = deviceStateSubject.eraseToAnyPublisher()
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

    public func fetchDeviceInfo(_ device: BTWXMDevice) {
        prepareDevice(device) { [weak self] in
            self?.helper?.fetchDeviceInformation()
        }
    }

    public func setDeviceFrequency(_ device: BTWXMDevice, frequency: Frequency) {
        prepareDevice(device) { [weak self] in
            self?.helper?.setFrequency(frequency)
        }
    }

    public func rebootDevice(_ device: BTWXMDevice) {
        /// Once the frequency set is finished, disconnecting we enforce the station to reboot.
        /// Afterwards we try to reconnect once we are connected again we assume the reboot state is over
        rebootStationWorkItem?.cancel()
        deviceStateSubject.send(.rebooting)
        manager.disconnect(from: device)
        connectToDevice(device, retries: 5)
    }

    public func connect(device: BTWXMDevice) {
        manager.connect(to: device) { [weak self] error in
            guard let self, error == nil else {
                self?.handleError(BTError(managerError: error!))
                return
            }
            self.deviceStateSubject.send(.connected)
        }
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

    public func cancelReboot() {
        rebootStationWorkItem?.cancel()
    }

	public func setFrequency(_ device: BTWXMDevice, frequency: Frequency) async -> BluetoothHeliumError? {
		await bluetoothWrapper.setDeviceFrequency(device, frequency: frequency)?.toBluetoothError
	}
}

private extension BluetoothDevicesRepositoryImpl {
    func prepareDevice(_ device: BTWXMDevice, callback: @escaping () -> Void) {
        guard
            let deviceWithCBPeripheral = manager._devices.first(where: { $0.wxmDevice == device })
        else {
            handleError(.wxmDeviceNotFound)
            return
        }

        prepareHeliumDeviceBluetoothHelperForDevice(deviceWithCBPeripheral)

        manager.connect(to: device) { [weak self] error in
            guard let self, error == nil else {
                self?.handleError(BTError(managerError: error!))
                return
            }
            if self.helper == nil {
                self.handleError(.helperNotReady)
                return
            }

            callback()
        }
    }

    private func prepareHeliumDeviceBluetoothHelperForDevice(_ device: WXMDeviceWithCBPeripheral) {
        if helper?.device.wxmDevice == device.wxmDevice {
            return
        }

        helper = HeliumDeviceBluetoothHelper(device: device)
        helper?.state.sink { [weak self] state in
            self?.deviceStateSubject.send(state.toDomainState())
        }.store(in: &cancellableSet)
    }

    private func handleError(_ error: BTError?) {
        print("BluetoothDevicesRepositoryImpl error: \(error)")
        if let wxmDevice = helper?.device.wxmDevice {
            manager.disconnect(from: wxmDevice)
        }

        switch error {
        case .wxmDeviceNotFound:
            deviceStateSubject.send(.error(DeviceState.HeliumDeviceError(code: "-1")))
        case .peripheralConnectionError:
            deviceStateSubject.send(.connectionError)
        case .helperNotReady:
            deviceStateSubject.send(.error(DeviceState.HeliumDeviceError(code: "-1")))
        case let .helperError(heliumDeviceError):
            deviceStateSubject.send(.error(heliumDeviceError.toDomainHeliumDeviceError()))
        default:
            deviceStateSubject.send(.connectionError)
        }
    }

    func connectToDevice(_ device: BTWXMDevice, retries: Int) {
        let workItem = DispatchWorkItem { [weak self] in
            self?.manager.connect(to: device) { error in
                if error == nil {
                    self?.deviceStateSubject.send(.rebootingSuccess)
                    return
                }

                if retries > 0 {
                    self?.connectToDevice(device, retries: retries - 1)
                    return
                }

                self?.deviceStateSubject.send(.rebootingError)
            }
        }
        rebootStationWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: workItem)
    }
}

extension HeliumDeviceBluetoothHelper.HelperState {
    func toDomainState() -> DeviceState {
        switch self {
        case .idle:
            return .idle
        case .discoveringCharacteristics, .fetchingDevEUI, .fetchingClaimingKey:
            return .communicatingWithDevice
        case .settingFrequency:
            return .settingFrequency
        case let .fetchInfoSuccess(heliumDevice):
            return .success(heliumDevice)
        case let .error(helperError):
            return .error(
                helperError.toDomainHeliumDeviceError()
            )
        case .frequencySetSuccess:
            return .frequencySetSuccess
        case .frequencySetError:
            return .frequencySetError
        }
    }
}

extension HeliumDeviceBluetoothHelper.HeliumDeviceError {
    func toDomainHeliumDeviceError() -> DeviceState.HeliumDeviceError {
        switch self {
        case .serviceDiscovery:
            return DeviceState.HeliumDeviceError(code: "1")
        case .characteristicDiscovery:
            return DeviceState.HeliumDeviceError(code: "2")
        case .writeToCharacteristic:
            return DeviceState.HeliumDeviceError(code: "3")
        case .readFromCharacteristic:
            return DeviceState.HeliumDeviceError(code: "4")
        case .readValueInvalid:
            return DeviceState.HeliumDeviceError(code: "5")
        case .illegalStateEncountered:
            return DeviceState.HeliumDeviceError(code: "6")
        }
    }
}

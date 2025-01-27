//
//  BluetoothDevicesRepository.swift
//  DomainLayer
//
//  Created by Manolis Katsifarakis on 29/9/22.
//

import Combine

public protocol BluetoothDevicesRepository {
    var state: AnyPublisher<BluetoothState, Never> { get }
    var devices: AnyPublisher<[BTWXMDevice], Never> { get }

    func enable()

    func startScanning()
    func stopScanning()

	func fetchDeviceInfo(_ device: BTWXMDevice) async -> Result<BTWXMDeviceInfo?, BluetoothHeliumError>
	func setFrequency(_ device: BTWXMDevice, frequency: Frequency) async -> BluetoothHeliumError?
	func rebootDevice(_ device: BTWXMDevice) async -> BluetoothHeliumError?
	func connect(device: BTWXMDevice) async -> BluetoothHeliumError?
    func disconnect(device: BTWXMDevice)
}

public struct BTWXMDeviceInfo: Sendable {
	public let devEUI: String
	public let claimingKey: String

	public init(devEUI: String, claimingKey: String) {
		self.devEUI = devEUI
		self.claimingKey = claimingKey
	}
}

public enum BluetoothState: Sendable {
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
    case unknown
    case resetting
}

public enum BTWXMDeviceState: String, Sendable {
    case unknown
    case disconnected
    case connecting
    case connected
    case disconnecting
}

public struct BTWXMDevice: Equatable, Identifiable, Sendable {
    public var id: UUID {
        return identifier
    }

    public let identifier: UUID
    public let state: BTWXMDeviceState
    public let name: String?
    public let rssi: Float
    public var eui: String?

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public init(
        identifier: UUID,
        state: BTWXMDeviceState,
        name: String?,
        rssi: Float,
        eui: String?
    ) {
        self.identifier = identifier
        self.state = state
        self.name = name
        self.rssi = rssi
        self.eui = eui
    }

    /// Checks if `BTWXMDevice` and the `NetworkDevicesResponse` are referring to the same station
    /// - Parameter device: The `NetworkDevicesResponse` to check
    /// - Returns: True if both instances are referring to the same station
    public func isSame(with device: DeviceDetails) -> Bool {
        guard let label = device.label, let name else {
            return false
        }

        let convetedLabel = label.replacingOccurrences(of: ":", with: "")
        let suffix = convetedLabel.suffix(6)
        return name.hasSuffix(suffix)
    }
}

public enum DeviceState {
    case idle
    case communicatingWithDevice
    case connected
    case connectionError
    case success(HeliumDevice)
    case settingFrequency
    case frequencySetSuccess
    case frequencySetError
    case rebooting
    case rebootingSuccess
    case rebootingError
    case error(HeliumDeviceError)

    public struct HeliumDeviceError: Error {
        public let code: String
        public init(code: String) {
            self.code = code
        }
    }
}

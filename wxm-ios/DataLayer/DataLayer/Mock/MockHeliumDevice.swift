//
//  MockHeliumDevice.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 12/3/25.
//

import Foundation
@preconcurrency import CoreBluetoothMock

// MARK: - Constants

extension CBMUUID {
	nonisolated(unsafe) static let service  = CBMUUID(string: "00034729-1212-EFDE-1523-785FEABCD123")
	nonisolated(unsafe) static let readCharacteristic = CBMUUID(string: "00049616-1212-EFDE-1523-785FEABCD123") // read
	nonisolated(unsafe) static let writeCharacteristic    = CBMUUID(string: "00034729-1212-EFDE-1523-785FEABCD123") // write
}

// MARK: - Services

extension CBMCharacteristicMock {

	static let readCharacteristic = CBMCharacteristicMock(
		type: .readCharacteristic,
		properties: [.notify, .read],
		descriptors: CBMClientCharacteristicConfigurationDescriptorMock()
	)

	static let writeCharacteristic = CBMCharacteristicMock(
		type: .writeCharacteristic,
		properties: [.write, .read, .notify]
	)

}

extension CBMServiceMock {

	static let service = CBMServiceMock(
		type: .service,
		primary: true,
		characteristics:
			.readCharacteristic,
			.writeCharacteristic
	)

}

// MARK: - Mock helium Implementation

/// The delegate implements the behavior of the mocked device.
private final class HeliumDevicePeripheralSpecDelegate: CBMPeripheralSpecDelegate, Sendable {


	nonisolated(unsafe) private var notifyingCharacteristic: CBMCharacteristicMock?

	// MARK: Event handlers

	func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveSetNotifyRequest enabled: Bool, for characteristic: CBMCharacteristicMock) -> Result<Void, any Error> {
		notifyingCharacteristic = characteristic
		return .success(())
	}

	func peripheral(_ peripheral: CBMPeripheralSpec,
					didReceiveReadRequestFor characteristic: CBMCharacteristicMock)
			-> Result<Data, Error> {
		if characteristic.uuid == .writeCharacteristic {
			return .success(Data())
		} else {
			return .success(Data())
		}
	}

	func peripheral(_ peripheral: CBMPeripheralSpec,
					didReceiveWriteRequestFor characteristic: CBMCharacteristicMock,
					data: Data) -> Result<Void, Error> {
		// Simulate value update to simulate the connection process with helium devices
		handleWriteData(data, for: peripheral)

		return .success(())
	}

	private func handleWriteData(_ data: Data, for peripheral: CBMPeripheralSpec) {
		guard let notifyingCharacteristic else {
			return
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			guard let command = String(data: data, encoding: .utf8) else {
				return
			}
			switch command {
				case BTCommands.AT_DEV_EUI_COMMAND, BTCommands.AT_CLAIMING_KEY_COMMAND:
					let value = "123".data(using: .utf8) ?? Data()
					peripheral.simulateValueUpdate(value, for: notifyingCharacteristic)
				default:
					let value = BTCommands.SUCCESS_RESPONSE.data(using: .utf8) ?? Data()
					peripheral.simulateValueUpdate(value, for: notifyingCharacteristic)
			}

		}
	}
}

let mockHelium = CBMPeripheralSpec
	.simulatePeripheral(proximity: .immediate)
	.advertising(
		advertisementData: [
			CBAdvertisementDataIsConnectable : true as NSNumber,
			CBAdvertisementDataLocalNameKey : "WXMDevice"
		],
		withInterval: 2.0,
		delay: 5.0,
		alsoWhenConnected: false
	)
	.advertising(
		advertisementData: [
			CBAdvertisementDataIsConnectable : false as NSNumber,
			CBAdvertisementDataLocalNameKey : "WXMDevice",
			//CBAdvertisementDataManufacturerDataKey:
		],
		withInterval: 4.0,
		delay: 2.0,
		alsoWhenConnected: false
	)
	.connectable(
		name: "WXMDevice",
		services: [.service],
		delegate: HeliumDevicePeripheralSpecDelegate()
	)
	.build()

let mockNotConnectableHelium = CBMPeripheralSpec
	.simulatePeripheral(proximity: .immediate)
	.advertising(
		advertisementData: [
			CBAdvertisementDataIsConnectable : true as NSNumber,
			CBAdvertisementDataLocalNameKey : "WXMDevice"
		],
		withInterval: 2.0,
		delay: 5.0,
		alsoWhenConnected: false
	)
	.advertising(
		advertisementData: [
			CBAdvertisementDataIsConnectable : false as NSNumber,
			CBAdvertisementDataLocalNameKey : "WXMDevice",
			//CBAdvertisementDataManufacturerDataKey:
		],
		withInterval: 4.0,
		delay: 2.0,
		alsoWhenConnected: false
	)
	.build()

let mockBTDevice = CBMPeripheralSpec
	.simulatePeripheral(proximity: .immediate)
	.advertising(
		advertisementData: [
			CBAdvertisementDataIsConnectable : true as NSNumber,
			CBAdvertisementDataLocalNameKey : "BTDevice"
		],
		withInterval: 2.0,
		delay: 5.0,
		alsoWhenConnected: false
	)
	.advertising(
		advertisementData: [
			CBAdvertisementDataIsConnectable : false as NSNumber,
			CBAdvertisementDataLocalNameKey : "BTDevice",
		],
		withInterval: 4.0,
		delay: 2.0,
		alsoWhenConnected: false
	)
	.connectable(
		name: "BTDevice",
		services: [.service],
		delegate: HeliumDevicePeripheralSpecDelegate()
	)
	.build()

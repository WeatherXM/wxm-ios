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
	nonisolated(unsafe) static let nordicBlinkyService  = CBMUUID(string: "00034729-1212-EFDE-1523-785FEABCD123")
	nonisolated(unsafe) static let buttonCharacteristic = CBMUUID(string: "00049616-1212-EFDE-1523-785FEABCD123") // read
	nonisolated(unsafe) static let ledCharacteristic    = CBMUUID(string: "00034729-1212-EFDE-1523-785FEABCD123") // write
}

// MARK: - Services

extension CBMCharacteristicMock {

	static let buttonCharacteristic = CBMCharacteristicMock(
		type: .buttonCharacteristic,
		properties: [.notify, .read],
		descriptors: CBMClientCharacteristicConfigurationDescriptorMock()
	)

	static let ledCharacteristic = CBMCharacteristicMock(
		type: .ledCharacteristic,
		properties: [.write, .read]
	)

}

extension CBMServiceMock {

	static let blinkyService = CBMServiceMock(
		type: .nordicBlinkyService,
		primary: true,
		characteristics:
			.buttonCharacteristic,
			.ledCharacteristic
	)

}

// MARK: - Blinky Implementation

/// The delegate implements the behavior of the mocked device.
private class BlinkyCBMPeripheralSpecDelegate: CBMPeripheralSpecDelegate {

	// MARK: States

	/// State of the LED.
	private var ledEnabled: Bool = false
	/// State of the Button.
	private var buttonPressed: Bool = false

	// MARK: Encoders

	/// LED state encoded as Data.
	///
	/// - 0x01 - LED is ON.
	/// - 0x00 - LED is OFF.
	private var ledData: Data {
		return ledEnabled ? Data([0x01]) : Data([0x00])
	}

	/// Button state encoded as Data.
	///
	/// - 0x01 - Button is pressed.
	/// - 0x00 - Button is released.
	private var buttonData: Data {
		return buttonPressed ? Data([0x01]) : Data([0x00])
	}

	// MARK: Event handlers

	func reset() {
		ledEnabled = false
		buttonPressed = false
	}

	func peripheral(_ peripheral: CBMPeripheralSpec,
					didReceiveReadRequestFor characteristic: CBMCharacteristicMock)
			-> Result<Data, Error> {
		if characteristic.uuid == .ledCharacteristic {
			return .success(ledData)
		} else {
			return .success(buttonData)
		}
	}

	func peripheral(_ peripheral: CBMPeripheralSpec,
					didReceiveWriteRequestFor characteristic: CBMCharacteristicMock,
					data: Data) -> Result<Void, Error> {
		if data.count > 0 {
			ledEnabled = data[0] != 0x00
		}
		peripheral.simulateValueUpdate(Data(), for: characteristic)
		return .success(())
	}
}

// MARK: - Blinky Definition

/// This device will advertise with 2 different types of packets, as nRF Blinky and an iBeacon (with a name).
/// As iOS prunes the iBeacon manufacturer data, only the name is available.
let blinky = CBMPeripheralSpec
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
		name: "nRF Blinky",
		services: [.blinkyService],
		delegate: BlinkyCBMPeripheralSpecDelegate()
	)
	.build()

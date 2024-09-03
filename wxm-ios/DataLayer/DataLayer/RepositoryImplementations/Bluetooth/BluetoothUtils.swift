//
//  BluetoothUtils.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 10/2/23.
//

import CoreBluetooth
import DomainLayer
import Foundation

enum BTCommands {
	static let READ_CHARACTERISTIC_UUID = "49616"
	static let WRITE_CHARACTERISTIC_UUID = "34729"
	static let AT_DEV_EUI_COMMAND = "AT+DEUI=?\r\n"
	static let AT_CLAIMING_KEY_COMMAND = "AT+CLAIM_KEY=?\r\n"
	static let AT_SET_FREQUENCY_COMMAND_FORMAT = "AT+BAND=%@\r\n"
	static let AT_SET_INTERVAL_COMMAND_FORMAT = "AT+INTERVAL=%d\r\n"
	static let SUCCESS_RESPONSE = "ok"
}

extension CBPeripheral {
	func isWXMDevice() -> Bool {
		// DfuTarg is returned when device gets in a "bricked" state, such as when
		// a user interrupts the update process. We need to include it in case the user
		// wants to retry updating it.
		let nameLC = name?.lowercased()
		return nameLC?.contains("WeatherXM".lowercased()) == true ||
		nameLC?.contains("DfuTarg".lowercased()) == true ||
		nameLC?.contains("WXM".lowercased()) == true
	}
}

extension Data {
	private static let hexAlphabet = Array("0123456789abcdef".unicodeScalars)
	func hexStringEncoded() -> String {
		String(reduce(into: "".unicodeScalars) { result, value in
			result.append(Self.hexAlphabet[Int(value / 0x10)])
			result.append(Self.hexAlphabet[Int(value % 0x10)])
		})
	}
	
	func convertedCharacteristicValue() -> String? {
		guard let valueString = String(data: self, encoding: .utf8)?
			.replacingOccurrences(of: "\n", with: "")
			.replacingOccurrences(of: "\r", with: "")
			.replacingOccurrences(of: "\'", with: "")
			.replacingOccurrences(of: ":", with: "")
		else {
			return nil
		}
		
		return valueString
	}
}

extension BTWXMDevice {
	init(cbPeripheral: CBPeripheral, rssi: NSNumber, eui: String?) {
		self.init(
			identifier: cbPeripheral.identifier,
			state: BTWXMDeviceState.fromCBPeripheralState(cbPeripheral.state),
			name: cbPeripheral.name,
			rssi: rssi.floatValue,
			eui: eui
		)
	}
}

extension BTWXMDeviceState {
	static func fromCBPeripheralState(_ state: CBPeripheralState) -> BTWXMDeviceState {
		switch state {
			case .disconnected:
				return disconnected
			case .connecting:
				return connecting
			case .connected:
				return connected
			case .disconnecting:
				return disconnecting
			@unknown default:
				return unknown
		}
	}
}

extension BluetoothManager.BTManagerEror {
	var toDomainBluetoothHeliumError: BluetoothHeliumError? {
		switch self {
			case .peripheralNotFound:
				return .peripheralNotFound
			case .connectionError:
				return .connectionError
			case .writeCommandError:
				return nil
			case .writeCommandDeviceNotConnectedError:
				return nil
		}
	}
}

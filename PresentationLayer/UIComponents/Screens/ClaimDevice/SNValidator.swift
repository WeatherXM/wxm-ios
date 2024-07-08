//
//  SNValidator.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/5/24.
//

import Foundation

struct SNValidator {
	private let DISALLOWED_CHARACTERS_REGEX = "[^0-9|A-F|a-f|:]"
	private let SEPARATOR_CHARACTER = ":"
	private let m5SerialNumberRegex = "^([0-9A-Fa-f]{2}:){8}[0-9A-Fa-f]{2}"
	private let d1SerialNumberRegex = "^([0-9A-Fa-f]{2}:){9}[0-9A-Fa-f]{2}"
	private let pulseSerialNumberRegex = "^[0-9A-Fa-f]{16}$"
	private let claimingKeyRegex = "^([0-9]{6})"
	private let inputClaimingKeyRegex = "^[0-9]{0,6}$"
	private let inputPulseSerialNumberRegex = "^[0-9A-Fa-f]{0,16}$"

	let type: DeviceType

	var serialNumberSegments: Int {
		switch type {
			case .m5:
				9
			case .d1:
				10
			case .pulse:
				8
		}
	}

	func validate(serialNumber: String) -> Bool {
		switch type {
			case .m5:
				serialNumber.matches(m5SerialNumberRegex)
			case .d1:
				serialNumber.matches(d1SerialNumberRegex)
			case .pulse:
				serialNumber.matches(pulseSerialNumberRegex)
		}
	}

	func validateStationKey(key: String) -> Bool {
		key.matches(claimingKeyRegex)
	}
	
	/// Validate if the string contains only digits with max length 6
	/// - Parameter key: The key to validate
	/// - Returns: True is the input matches the described criterias
	func validateStationKeyInput(key: String) -> Bool {
		key.matches(inputClaimingKeyRegex)
	}
	
	/// Validates the input while typing.
	/// If the already typed text contains valid characters returns true.
	/// - eg. For M5, `AA:12` is valid and `AA:M` isn't
	/// - Parameter input: The string to validate
	/// - Returns: `true` if the passed input is valid
	func validateSerialNumberInput(input: String) -> Bool {
		switch type {
			case .m5:
				return input.matches(m5SerialNumberRegex)
			case .d1:
				return input.matches(d1SerialNumberRegex)
			case .pulse:
				return input.matches(inputPulseSerialNumberRegex)
		}
	}
	
	/// Fixes the serial number to propagate it to the container.
	/// - For M5 and D1 just returns the serial number as is
	/// - For Pulse removes the initial "P" if exists
	/// - Parameter serialNumber: The serial number to be fixed
	/// - Returns: The fixed serial number
	func normalized(serialNumber: String) -> String {
		switch type {
			case .m5, .d1:
				return serialNumber
			case .pulse:
				var serial = serialNumber
				if serial.first == "P" {
					serial = String(serial.dropFirst())
				}
				return serial
		}
	}
}

extension SNValidator {
	enum DeviceType {
		case m5
		case d1
		case pulse
	}
}

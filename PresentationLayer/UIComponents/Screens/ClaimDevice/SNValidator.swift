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
}

extension SNValidator {
	enum DeviceType {
		case m5
		case d1
		case pulse
	}
}

//
//  SNValidator.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/5/24.
//

import Foundation

struct SNValidator {
	private let m5SerialNumberRegex = "^([0-9A-Fa-f]{2}:){8}[0-9A-Fa-f]{2}"
	private let d1SerialNumberRegex = "^([0-9A-Fa-f]{2}:){10}[0-9A-Fa-f]{2}"
	private let claimingKeyRegex = "^([0-9]{6})"

	func validateM5(serialNumber: String) -> Bool {
		serialNumber.matches(m5SerialNumberRegex)
	}

	func validateD1(serialNumber: String) -> Bool {
		serialNumber.matches(d1SerialNumberRegex)
	}

	func validateStationKey(key: String) -> Bool {
		key.matches(claimingKeyRegex)
	}
}

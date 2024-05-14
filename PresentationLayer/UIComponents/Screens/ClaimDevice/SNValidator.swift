//
//  SNValidator.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/5/24.
//

import Foundation

struct SNValidator {
	private let serialNumberRegex = "^([0-9A-Fa-f]{2}:){8}[0-9A-Fa-f]{2}"

	func validateQR(qrString: String) -> Bool {
		qrString.matches(serialNumberRegex)
	}

	func validateStationKey(key: String) -> Bool {
		key.count == 6
	}
}

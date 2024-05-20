//
//  ManualSerialNumberTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/5/24.
//

import Foundation
import UIKit

enum SerialNumberInputType: RawRepresentable, CustomStringConvertible {
	init?(rawValue: String) {
		fatalError("Not implemented initializer")
	}
	
	case claimingKey
	case serialNumber(SNValidator.DeviceType)

	var rawValue: String {
		switch self {
			case .claimingKey:
				"claimingKey"
			case .serialNumber:
				"serialNumber"
		}
	}

	var description: String {
		switch self {
			case .claimingKey:
				LocalizableString.ClaimDevice.enterGatewayClaimingKey.localized
			case .serialNumber:
				LocalizableString.ClaimDevice.enterGatewaySerialNumber.localized
		}
	}

	var placeholder: String {
		switch self {
			case .claimingKey:
				"123456"
			case .serialNumber(let type):
				UITextField.formatAsSerialNumber("", placeholder: "A", validator: .init(type: type))
		}
	}

	var keyboardType: UIKeyboardType {
		switch self {
			case .claimingKey:
					.numberPad
			case .serialNumber:
					.asciiCapable
		}
	}
}

struct SerialNumberInputField: Identifiable {
	let type: SerialNumberInputType
	var value: String

	var id: String {
		type.description
	}
	
	mutating func setValue(value: String) {
		self.value = value
	}
}

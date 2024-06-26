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
				return "123456"
			case .serialNumber(let type):
				switch type {
					case .m5, .d1:
						return UITextField.formatAsSerialNumber("", 
																placeholder: "A",
																validator: .init(type: type))
					case .pulse:
						return "P1234567890123456"
				}
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

/// The result to propagate to the container
struct InputFieldResult {
	let type: SerialNumberInputType
	var value: String
}

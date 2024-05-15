//
//  ManualSerialNumberTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/5/24.
//

import Foundation
import UIKit

enum SerialNumberInputType: CustomStringConvertible {
	case claimingKey
	case serialNumber

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
			case .serialNumber:
				UITextField.formatAsSerialNumber("", placeholder: "A")
		}
	}
}

struct SerialNumberInputField: Identifiable {
	let type: SerialNumberInputType
	var value: String

	var id: SerialNumberInputType {
		type
	}
	
	mutating func setValue(value: String) {
		self.value = value
	}
}

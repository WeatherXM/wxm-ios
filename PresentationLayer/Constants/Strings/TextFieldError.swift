//
//  TextFieldError.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 2/6/22.
//

import Foundation

enum TextFieldError: String {
	case emptyField, invalidSerialNumber, invalidNewAddress, invalidPassword, invalidDeviceEUIKey
	
	var description: String {
		switch self {
			case .emptyField:
				return "Cannot be empty"
			case .invalidSerialNumber:
				return "Invalid serial number"
			case .invalidNewAddress:
				return "Invalid WXM Address"
			case .invalidPassword:
				return "Wrong password!"
			case .invalidDeviceEUIKey:
				return LocalizableString.ClaimDevice.heliumInvalidEUIKey.localized
		}
	}
}

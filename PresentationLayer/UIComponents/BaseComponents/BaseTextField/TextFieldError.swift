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
				return LocalizableString.Error.emtyTextField.localized
			case .invalidSerialNumber:
				return LocalizableString.Error.invalidSerialNumber.localized
			case .invalidNewAddress:
				return LocalizableString.Error.invalidWXMAddress.localized
			case .invalidPassword:
				return LocalizableString.Error.invalidPassword.localized
			case .invalidDeviceEUIKey:
				return LocalizableString.ClaimDevice.heliumInvalidEUIKey.localized
		}
	}
}
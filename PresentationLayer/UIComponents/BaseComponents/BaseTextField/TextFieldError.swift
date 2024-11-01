//
//  TextFieldError.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 2/6/22.
//

import Foundation

enum TextFieldError: CustomStringConvertible, Equatable {
	case emptyField
	case invalidSerialNumber
	case invalidNewAddress
	case invalidPassword
	case invalidDeviceEUIKey
	case custom(String)

	var description: String {
		switch self {
			case .emptyField:
				return LocalizableString.Error.emptyTextField.localized
			case .invalidSerialNumber:
				return LocalizableString.Error.invalidSerialNumber.localized
			case .invalidNewAddress:
				return LocalizableString.Error.invalidWXMAddress.localized
			case .invalidPassword:
				return LocalizableString.Error.invalidPassword.localized
			case .invalidDeviceEUIKey:
				return LocalizableString.ClaimDevice.heliumInvalidEUIKey.localized
			case .custom(let text):
				return text
		}
	}
}

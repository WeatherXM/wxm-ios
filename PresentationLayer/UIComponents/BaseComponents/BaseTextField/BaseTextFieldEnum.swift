//
//  BaseTextFieldEnum.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 10/5/22.
//

import SwiftUI

enum BaseTextFieldEnum {
    case user
    case name
    case surname
    case password
    case email
    case mandatoryEmail
    case qrCodesScan
    case serialNumber
    case currentWXMAddress
    case newWXMAddress
    case heliumDeviceDevEUI
    case heliumDeviceKey
    case locationSearch
    case accountConfirmation

    var isPassword: Bool {
        switch self {
            case .password, .accountConfirmation:
                return true
            default:
                return false
        }
    }

    var leftIcon: Image? {
        switch self {
            case .user, .name, .surname:
                return Image(asset: .user)
            case .password, .accountConfirmation:
                return Image(asset: .lock)
            case .email, .mandatoryEmail:
                return Image(asset: .email)
            default:
                return nil
        }
    }

    var rightIcon: Image? {
        switch self {
            case .password, .accountConfirmation:
                return Image(asset: .eye)
            case .qrCodesScan:
                return Image(asset: .qrCode)
            case .locationSearch:
                return Image(asset: .search)
            default:
                return nil
        }
    }

    var label: String {
        switch self {
            case .user, .email:
                return LocalizableString.email.localized
            case .mandatoryEmail:
                return LocalizableString.mandatoryEmail.localized
            case .name:
                return LocalizableString.firstName.localized
            case .surname:
                return LocalizableString.lastName.localized
            case .password:
                return LocalizableString.password.localized
            case .serialNumber:
                return LocalizableString.ClaimDevice.enterSerialNumberTitle.localized
            case .qrCodesScan:
                return LocalizableString.Wallet.enterAddressTitle.localized
            case .newWXMAddress:
                return LocalizableString.Wallet.enterAddressTitle.localized
            case .heliumDeviceDevEUI:
                return LocalizableString.ClaimDevice.devEUIFieldHint.localized
            case .heliumDeviceKey:
                return LocalizableString.ClaimDevice.keyFieldHint.localized
            case .locationSearch:
                return LocalizableString.ClaimDevice.confirmLocationSearchHint.localized
            case .accountConfirmation:
                return LocalizableString.typeYourPassword.localized
            default:
                return ""
        }
    }
}

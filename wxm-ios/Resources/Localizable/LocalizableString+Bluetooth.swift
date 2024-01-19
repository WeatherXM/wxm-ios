//
//  LocalizableString+Bluetooth.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/9/23.
//

import Foundation

extension LocalizableString {
    enum Bluetooth {
        case noAccessTitle
        case noAccessText(String)
        case noDevicesFoundTitle
        case noDevicesFoundText
        case noDevicesFoundTextMarkdown
        case goToSettingsGrantAccess
        case title
        case offText(String)
        case unsupportedTitle
        case unsupportedText(String)
    }
}

extension LocalizableString.Bluetooth: WXMLocalizable {
    
    var localized: String {
        var localized = NSLocalizedString(key, comment: "")
        switch self {
            case .noAccessText(let text), .offText(let text), .unsupportedText(let text):
                localized = String(format: localized, text)
            default: break
        }

        return localized
    }

    var key: String {
        switch self {
            case .noAccessTitle:
                return "bluetooth_no_access_title"
            case .noAccessText:
                return "bluetooth_no_access_text_format"
            case .noDevicesFoundTitle:
                return "bluetooth_no_devices_found_title"
            case .noDevicesFoundText:
                return "bluetooth_no_devices_found_text"
            case .noDevicesFoundTextMarkdown:
                return "bluetooth_no_devices_found_text_markdown"
            case .goToSettingsGrantAccess:
                return "bluetooth_go_to_settings_grant_access"
            case .title:
                return "bluetooth_title"
            case .offText:
                return "bluetooth_off_text_format"
            case .unsupportedTitle:
                return "bluetooth_unsupported_title"
            case .unsupportedText:
                return "bluetooth_unsupported_text_format"
        }
    }
}

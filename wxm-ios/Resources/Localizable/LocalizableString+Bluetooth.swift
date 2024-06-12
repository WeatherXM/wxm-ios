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
        case noDevicesFoundTitle
        case noDevicesFoundText
        case noDevicesFoundTextMarkdown
        case goToSettingsGrantAccess
        case title
        case offText
        case unsupportedTitle
    }
}

extension LocalizableString.Bluetooth: WXMLocalizable {
    
    var localized: String {
        let localized = NSLocalizedString(key, comment: "")
        return localized
    }

    var key: String {
        switch self {
            case .noAccessTitle:
                return "bluetooth_no_access_title"
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
                return "bluetooth_off_text"
            case .unsupportedTitle:
                return "bluetooth_unsupported_title"
        }
    }
}

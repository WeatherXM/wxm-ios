//
//  LocalizableString+Settings.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 12/9/23.
//

import Foundation

extension LocalizableString {
    enum Settings {
        case weatherUnits
		case notifications
		case notificationsDescription
        case help
        case deleteMyAccount
        case documentation
        case documentationDescription
        case contactSupportDescritpion
        case deleteAccountCaption
        case deleteAccountWarning
    }
}

extension LocalizableString.Settings: WXMLocalizable {
    var localized: String {
        NSLocalizedString(key, comment: "")
    }

    var key: String {
        switch self {
            case .weatherUnits:
                return "settings_weather_units"
			case .notifications:
				return "settings_notifications"
			case .notificationsDescription:
				return "settings_notifications_description"
            case .help:
                return "settings_help"
            case .deleteMyAccount:
                return "settings_delete_my_account"
            case .documentation:
                return "settings_documentation"
            case .documentationDescription:
                return "settings_documentation_description"
            case .contactSupportDescritpion:
                return "settings_contact_support_descritpion"
            case .deleteAccountCaption:
                return "settings_delete_account_caption"
            case .deleteAccountWarning:
                return "settings_delete_account_warning"
        }
    }
}

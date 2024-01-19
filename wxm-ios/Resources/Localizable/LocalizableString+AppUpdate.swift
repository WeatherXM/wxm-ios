//
//  LocalizableString+AppUpdate.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/12/23.
//

import Foundation

extension LocalizableString {
	enum AppUpdate {
		case title
		case description
		case whatsNewTitle
		case updateButtonTitle
		case noUpdateButtonTitle
	}
}

extension LocalizableString.AppUpdate: WXMLocalizable {
	var localized: String {
		NSLocalizedString(key, comment: "")
	}

	var key: String {
		switch self {
			case .title:
				return "app_update_title"
			case .description:
				return "app_update_description"
			case .whatsNewTitle:
				return "app_update_whats_new_title"
			case .updateButtonTitle:
				return "app_update_update_button_title"
			case .noUpdateButtonTitle:
				return "app_update_no_update_button_title"
		}
	}
}

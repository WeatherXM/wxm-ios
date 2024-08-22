//
//  LocalizableString+Units.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/8/24.
//

import Foundation

extension LocalizableString {
	enum Units {
		case celsiusFriendlyName
	}
}

extension LocalizableString.Units: WXMLocalizable {
	var localized: String {
		let localized = NSLocalizedString(key, tableName: "Localizable_Units", comment: "")
		return localized
	}

	var key: String {
		switch self {
			case .celsiusFriendlyName:
				return "units_celsius_friendly_name"
		}
	}
}

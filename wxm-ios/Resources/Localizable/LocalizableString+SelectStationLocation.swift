//
//  LocalizableString+SelectStationLocation.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/12/23.
//

import Foundation

extension LocalizableString {
	enum SelectStationLocation {
		case title
		case searchPlaceholder
		case termsText
		case warningText(String)
		case buttonTitle
	}
}

extension LocalizableString.SelectStationLocation: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		switch self {
			case .warningText(let text):
				localized = String(format: localized, text)
			default: break
		}

		return localized
	}

	var key: String {
		switch self {
			case .title:
				return "select_station_location_title"
			case .searchPlaceholder:
				return "select_station_location_search_placeholder"
			case .termsText:
				return "select_station_location_terms_text"
			case .warningText:
				return "select_station_location_warning_text_format"
			case .buttonTitle:
				return "select_station_location_button_title"
		}
	}
}

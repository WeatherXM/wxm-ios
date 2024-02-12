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
		case successTitle
		case successDescription
		case successButtonTitle
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
			case .successTitle:
				return "select_station_success_title"
			case .successDescription:
				return "select_station_success_description"
			case .successButtonTitle:
				return "select_station_success_button_title"
		}
	}
}

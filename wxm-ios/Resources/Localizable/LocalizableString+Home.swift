//
//  LocalizableString+Home.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import Foundation

extension LocalizableString {
	enum Home {
		case searchPlaceholder
		case currentLocation
		case allowLocationPermission
		case locations
		case savedLocations
		case savedLocationsEmptyTitle
		case savedLocationsEmptyDescription
	}
}

extension LocalizableString.Home: WXMLocalizable {
	var localized: String {
		var localized = NSLocalizedString(key, comment: "")
		return localized
	}

	var key: String {
		switch self {
			case .searchPlaceholder:
				"home_search_placeholder"
			case .currentLocation:
				"home_current_location"
			case .allowLocationPermission:
				"home_allow_location_permission"
			case .locations:
				"home_locations"
			case .savedLocations:
				"home_saved_locations"
			case .savedLocationsEmptyTitle:
				"home_saved_locations_empty_title"
			case .savedLocationsEmptyDescription:
				"home_save_locations_empty_description"
		}
	}
}

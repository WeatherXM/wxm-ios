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
		case fahrenheitFriendlyName
		case millimetersFriendlyName
		case inchesFriendlyName
		case kilometersPerHourFriendlyName
		case milesPerHourFriendlyName
		case metersPerSecondFriendlyName
		case knotsFriendlyName
		case beaufortFriendlyName
		case cardinalFriendlyName
		case degreesFriendlyName
		case hectopascalFriendlyName
		case inchOfMercuryFriendlyName
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
				"units_celsius_friendly_name"
			case .fahrenheitFriendlyName:
				"units_fahrenheit_friendly_name"
			case .millimetersFriendlyName:
				"units_millimeters_friendly_name"
			case .inchesFriendlyName:
				"units_inches_friendly_name"
			case .kilometersPerHourFriendlyName:
				"units_km_per_hour_friendly_name"
			case .milesPerHourFriendlyName:
				"units_miles_per_hour_friendly_name"
			case .metersPerSecondFriendlyName:
				"units_meters_per_second_friendly_name"
			case .knotsFriendlyName:
				"units_knots_friendly_name"
			case .beaufortFriendlyName:
				"units_beaufort_friendly_name"
			case .cardinalFriendlyName:
				"units_cardinal_friendly_name"
			case .degreesFriendlyName:
				"units_degrees_friendly_name"
			case .hectopascalFriendlyName:
				"units_hectopascal_friendly_name"
			case .inchOfMercuryFriendlyName:
				"units_inch_of_mercury_friendly_name"
		}
	}
}

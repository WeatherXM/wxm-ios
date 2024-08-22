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
		case celsiusSymbol
		case fahrenheitSymbol
		case millimetersSymbol
		case inchesSymbol
		case kilometersPerHourSymbol
		case milesPerHourSymbol
		case metersPerSecondSymbol
		case knotsSymbol
		case beaufortSymbol
		case cardinalSymbol
		case degreesSymbol
		case hectopascalSymbol
		case inchOfMercurySymbol
		case uvSymbol
		case millimetersPerHourSymbol
		case inchesPerHourSymbol
		case wattsPerSquareSymbol
		case dBmSymbol

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
			case .celsiusSymbol:
				"units_celsius_symbol"
			case .fahrenheitSymbol:
				"units_fahrenheit_symbol"
			case .millimetersSymbol:
				"units_millimeters_symbol"
			case .inchesSymbol:
				"units_inches_symbol"
			case .kilometersPerHourSymbol:
				"units_km_per_hour_symbol"
			case .milesPerHourSymbol:
				"units_miles_per_hour_symbol"
			case .metersPerSecondSymbol:
				"units_meters_per_second_symbol"
			case .knotsSymbol:
				"units_knots_symbol"
			case .beaufortSymbol:
				"units_beaufort_symbol"
			case .cardinalSymbol:
				"units_cardinal_symbol"
			case .degreesSymbol:
				"units_degrees_symbol"
			case .hectopascalSymbol:
				"units_hectopascal_symbol"
			case .inchOfMercurySymbol:
				"units_inch_of_mercury_symbol"
			case .uvSymbol:
				"units_uv_symbol"
			case .millimetersPerHourSymbol:
				"units_millimeters_per_hour_symbol"
			case .inchesPerHourSymbol:
				"units_inches_per_hour_symbol"
			case .wattsPerSquareSymbol:
				"units_watts_per_square_symbol"
			case .dBmSymbol:
				"units_dbm_symbol"
		}
	}
}

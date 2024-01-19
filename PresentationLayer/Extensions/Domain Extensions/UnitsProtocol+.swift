//
//  UnitsProtocol+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 10/5/23.
//

import Foundation
import DomainLayer

protocol UnitsProtocolPresentable: UnitsProtocol {
	var unit: String { get }
	var settingUnitFriendlyName: String { get }
}

extension TemperatureUnitsEnum: UnitsProtocolPresentable {
	public var unit: String {
		switch self {
			case .celsius:
				return UnitConstants.CELCIUS
			case .fahrenheit:
				return UnitConstants.FAHRENHEIT
		}
	}

	public var settingUnitFriendlyName: String {
		switch self {
			case .celsius:
				return "Celsius (°C)"
			case .fahrenheit:
				return "Fahrenheit (°F)"
		}
	}
}

extension PrecipitationUnitsEnum: UnitsProtocolPresentable {
	public var unit: String {
		switch self {
			case .millimeters:
				return UnitConstants.MILLIMETERS
			case .inches:
				return UnitConstants.INCHES
		}
	}

	public var settingUnitFriendlyName: String {
		switch self {
			case .millimeters:
				return "Millimeters (mm)"
			case .inches:
				return "Inches (in)"
		}
	}
}

extension WindSpeedUnitsEnum: UnitsProtocolPresentable {
	public var unit: String {
		switch self {
			case .kilometersPerHour:
				return UnitConstants.KILOMETERS_PER_HOUR
			case .milesPerHour:
				return UnitConstants.MILES_PER_HOUR
			case .metersPerSecond:
				return UnitConstants.METERS_PER_SECOND
			case .knots:
				return UnitConstants.KNOTS
			case .beaufort:
				return UnitConstants.BEAUFORT
		}
	}

	public var settingUnitFriendlyName: String {
		switch self {
			case .kilometersPerHour:
				return "Kilometers per hour (km/h)"
			case .milesPerHour:
				return "Miles per hour (mph)"
			case .metersPerSecond:
				return "Meters per second (m/s)"
			case .knots:
				return "Knots (kn)"
			case .beaufort:
				return "Beaufort (bf)"
		}
	}
}

extension WindDirectionUnitsEnum: UnitsProtocolPresentable {
	public var unit: String {
		switch self {
			case .cardinal:
				return UnitConstants.CARDINAL
			case .degrees:
				return UnitConstants.DEGREES
		}
	}

	public var settingUnitFriendlyName: String {
		switch self {
			case .cardinal:
				return "Cardinal (e.g. N, SW, NE, etc)"
			case .degrees:
				return "Degrees"
		}
	}
}

extension PressureUnitsEnum: UnitsProtocolPresentable {
	public var unit: String {
		switch self {
			case .hectopascal:
				return UnitConstants.HECTOPASCAL
			case .inchOfMercury:
				return UnitConstants.INCH_OF_MERCURY
		}
	}

	public var settingUnitFriendlyName: String {
		switch self {
			case .hectopascal:
				return "Hectopascal (hPa)"
			case .inchOfMercury:
				return "Inch of mercury (inHg)"
		}
	}

}

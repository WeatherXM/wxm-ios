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
				return LocalizableString.Units.celsiusFriendlyName.localized
			case .fahrenheit:
				return LocalizableString.Units.fahrenheitFriendlyName.localized
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
				return LocalizableString.Units.millimetersFriendlyName.localized
			case .inches:
				return LocalizableString.Units.inchesFriendlyName.localized
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
				return LocalizableString.Units.kilometersPerHourFriendlyName.localized
			case .milesPerHour:
				return LocalizableString.Units.milesPerHourFriendlyName.localized
			case .metersPerSecond:
				return LocalizableString.Units.metersPerSecondFriendlyName.localized
			case .knots:
				return LocalizableString.Units.knotsFriendlyName.localized
			case .beaufort:
				return LocalizableString.Units.beaufortFriendlyName.localized
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
				return LocalizableString.Units.cardinalFriendlyName.localized
			case .degrees:
				return LocalizableString.Units.degreesFriendlyName.localized
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
				return LocalizableString.Units.hectopascalFriendlyName.localized
			case .inchOfMercury:
				return LocalizableString.Units.inchOfMercuryFriendlyName.localized
		}
	}

}

//
//  UnitConstants.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 2/9/22.
//

public enum UnitConstants {
	public static let CELCIUS = LocalizableString.Units.celsiusSymbol.localized.fixedLinebreaks
	public static let FAHRENHEIT = LocalizableString.Units.fahrenheitSymbol.localized.fixedLinebreaks
	public static let MILLIMETERS = LocalizableString.Units.millimetersSymbol.localized.fixedLinebreaks
	public static let INCHES = LocalizableString.Units.inchesSymbol.localized.fixedLinebreaks
	public static let KILOMETERS_PER_HOUR = LocalizableString.Units.kilometersPerHourSymbol.localized.fixedLinebreaks
	public static let MILES_PER_HOUR = LocalizableString.Units.milesPerHourSymbol.localized.fixedLinebreaks
	public static let METERS_PER_SECOND = LocalizableString.Units.metersPerSecondSymbol.localized.fixedLinebreaks
	public static let KNOTS = LocalizableString.Units.knotsSymbol.localized.fixedLinebreaks
	public static let BEAUFORT = LocalizableString.Units.beaufortSymbol.localized.fixedLinebreaks
	public static let CARDINAL = LocalizableString.Units.cardinalSymbol.localized.fixedLinebreaks
	public static let DEGREES = LocalizableString.Units.degreesSymbol.localized.fixedLinebreaks
	public static let HECTOPASCAL = LocalizableString.Units.hectopascalSymbol.localized.fixedLinebreaks
	public static let INCH_OF_MERCURY = LocalizableString.Units.inchOfMercurySymbol.localized.fixedLinebreaks
	public static let UV = LocalizableString.Units.uvSymbol.localized.fixedLinebreaks
    public static let PERCENT = "%".fixedLinebreaks
	public static let MILLIMETERS_PER_HOUR = LocalizableString.Units.millimetersPerHourSymbol.localized.fixedLinebreaks
	public static let INCHES_PER_HOUR = LocalizableString.Units.inchesPerHourSymbol.localized.fixedLinebreaks
	public static let WATTS_PER_SQR = LocalizableString.Units.wattsPerSquareSymbol.localized.fixedLinebreaks
	public static let DBM = LocalizableString.Units.dBmSymbol.localized.fixedLinebreaks
}

private extension String {
	var fixedLinebreaks: String {
		replacingOccurrences(of: "/", with: "\u{FEFF}/\u{FEFF}")
	}
}

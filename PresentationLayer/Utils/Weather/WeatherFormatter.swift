//
//  WeatherFormatter.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/5/23.
//

import Foundation
import DomainLayer
import Toolkit

typealias WeatherValueLiterals = (value: String, unit: String)

struct WeatherFormatter {
	private let unitsConverter = UnitsConverter()
	
    /// The values should be converted  before generate.
    /// When is true, is expected the passed values are in the "default" units. eg. temperature in Celsius
    /// By default is true
    var shouldConvert: Bool = true

    /// The text components of the pressure value. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Parameter unit: The requested unit
    /// - Returns: tuple with the text components eg. ("24.90", "inHg")
    func getPressureLiterals(pressure: Double?, unit: PressureUnitsEnum) -> WeatherValueLiterals {
        var pressureValue = pressure ?? Double.nan
        switch unit {
            case .hectopascal:
                let pressureMetric = UnitConstants.HECTOPASCAL
				return ("\(pressureValue.toPrecisionString(precision: 1))", pressureMetric)
            case .inchOfMercury:
                let pressureMetric = UnitConstants.INCH_OF_MERCURY
				pressureValue = (shouldConvert ? unitsConverter.hpaToInHg(hpa: pressureValue) : pressureValue)
                return ("\(pressureValue.toPrecisionString(precision: 2))", pressureMetric)
        }
    }

    /// The text components of the humidity. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Returns: A tuple with the text components eg. ("12", "%")
    func getHumidityLiterals(value: Int?) -> WeatherValueLiterals {
        ("\(value ?? 0)", UnitConstants.PERCENT)
    }

    /// The text components of the temperature. (value, unit)
    /// - Parameter unit: The requested unit
    /// - Parameter temperature: The value to generate the formatted value
    /// - Returns: A tuple with the text components eg. ("12", "°C")
	func getTemperatureLiterals(temperature: Double, unit: TemperatureUnitsEnum, decimals: Int = 1) -> WeatherValueLiterals {
        switch unit {
            case .celsius:
				return (temperature.toPrecisionString(minDecimals: decimals, precision: decimals), LocalizableString.celsiusSymbol.localized)
            case .fahrenheit:
				let value = shouldConvert ? unitsConverter.celsiusToFahrenheit(celsius: temperature) : temperature
				return (value.toPrecisionString(minDecimals: decimals, precision: decimals), LocalizableString.fahrenheitSymbol.localized)
        }
    }

    /// The text components of the wind value. (value, unit)
    /// - Parameters:
    ///   - value: The value to generate the formatted value
    ///   - windDirection: The direction index
    ///   - speedUnit: The requested speed unit
    ///   - directionUnit: The requested direction unit
    ///   - includeDirection: True if should include the direction part
    /// - Returns: A tuple with the text components eg. ("24.0", "km/h NW")
    func getWindValueLiterals(value: Double?,
                              windDirection: Int? = nil,
                              speedUnit: WindSpeedUnitsEnum,
                              directionUnit: WindDirectionUnitsEnum,
                              includeDirection: Bool) -> WeatherValueLiterals {
        var windUnit = ""
        var windSpeed: Double = value ?? 0.0
		var showDecimals = true

        switch speedUnit {
            case .kilometersPerHour:
				windSpeed = shouldConvert ? unitsConverter.msToKmh(ms: windSpeed) : windSpeed
                windUnit = UnitConstants.KILOMETERS_PER_HOUR
            case .milesPerHour:
				windSpeed = shouldConvert ? unitsConverter.msToMph(ms: windSpeed) : windSpeed
                windUnit = UnitConstants.MILES_PER_HOUR
            case .metersPerSecond:
                windUnit = UnitConstants.METERS_PER_SECOND
            case .knots:
				windSpeed = shouldConvert ? unitsConverter.msToKnots(ms: windSpeed) : windSpeed
                windUnit = UnitConstants.KNOTS
            case .beaufort:
				windSpeed = shouldConvert ? Double(unitsConverter.msToBeaufort(ms: windSpeed)) : windSpeed
                windUnit = UnitConstants.BEAUFORT
				showDecimals = false
        }

        var windDirectionString = "\(windDirection ?? 0)°"
        if directionUnit == .cardinal {
			windDirectionString = unitsConverter.degreesToCardinal(value: windDirection ?? 0)
        }

		let convertedValue = windSpeed.rounded(toPlaces: 1)
		let convertedValueStr = showDecimals ? "\(convertedValue.toPrecisionString(minDecimals: 1, precision: 1))" : "\(Int(convertedValue))"
        return ("\(convertedValueStr)", "\(windUnit) \(includeDirection ? windDirectionString : "")".trimWhiteSpaces())
    }

    /// The text components of the UV. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Returns: A tuple with the text components eg. ("2", "")
    func getUVLiterals(value: Int?) -> WeatherValueLiterals {
        let valueStr = "\(value ?? 0)"
		let unit = {
			guard let value else {
				return ""
			}
			switch value {
				case 0...2:
					return LocalizableString.low.localized
				case 3...5:
					return LocalizableString.moderate.localized
				case 6...7:
					return LocalizableString.high.localized
				case 8...10:
					return LocalizableString.veryHigh.localized
				case _ where value >= 11:
					return LocalizableString.extreme.localized
				default:
					return ""
			}
		}()
        return (valueStr, unit)
    }

    /// The text components of the solar radiation. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Returns: A tuple with the text components eg. ("12.2", "W/m2")
    func getSolarRadiationLiterals(value: Double?) -> WeatherValueLiterals {
		("\((value ?? 0.0).toPrecisionString(minDecimals: 1, precision: 1))", UnitConstants.WATTS_PER_SQR)
    }

    /// The text components of the precipitation value. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Parameter unit: The requested unit
    /// - Returns:  tuple with the text components eg. ("5.0", "mm/h")
    func getPrecipitationLiterals(value: Double?, unit: PrecipitationUnitsEnum) -> WeatherValueLiterals {
        switch unit {
            case .millimeters:
				return ("\((value ?? .nan).toPrecisionString(minDecimals: 1, precision: 1))", UnitConstants.MILLIMETERS_PER_HOUR)
            case .inches:
				let convertedValue = (shouldConvert ? unitsConverter.millimetersToInches(mm: value ?? Double.nan) : value ?? Double.nan)
				return (convertedValue.toPrecisionString(minDecimals: 2, precision: 2), UnitConstants.INCHES_PER_HOUR)
        }
    }

    /// The text components of the precipitation accumulated value. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Parameter unit: The requested unit
    /// - Returns:  tuple with the text components eg. ("5.0", "mm")
    func getPrecipitationAccumulatedLiterals(from value: Double?, unit: PrecipitationUnitsEnum) -> WeatherValueLiterals? {
        switch unit {
            case .millimeters:
                return ((value ?? 0.0).toPrecisionString(minDecimals: 1, precision: 1), UnitConstants.MILLIMETERS)
            case .inches:
				let convertedValue = (shouldConvert ? unitsConverter.millimetersToInches(mm: value ?? 0.0) : value ?? 0.0)
                return (convertedValue.toPrecisionString(minDecimals: 2, precision: 2), UnitConstants.INCHES)
        }
    }

    /// The text components of the precipitation probability. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Returns: A tuple with the text components eg. ("12", "%")
    func getPrecipitationProbabilityLiterals(value: Double?) -> WeatherValueLiterals {
        ("\(Int(value?.rounded(toPlaces: 0) ?? 0))", UnitConstants.PERCENT)
    }
}

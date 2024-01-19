//
//  WeatherFormatter.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/5/23.
//

import Foundation
import DomainLayer

typealias WeatherValueLiterals = (value: String, unit: String)

struct WeatherFormatter {
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
                pressureValue = pressureValue.rounded(toPlaces: 1)
                return ("\(pressureValue)", pressureMetric)
            case .inchOfMercury:
                let pressureMetric = UnitConstants.INCH_OF_MERCURY
                let pressureValue = (shouldConvert ? hpaToInHg(hpa: pressureValue) : pressureValue).rounded(toPlaces: 2)
                return ("\(pressureValue)", pressureMetric)
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
    func getTemperatureLiterals(temperature: Double, unit: TemperatureUnitsEnum) -> WeatherValueLiterals {
        let format = "%.1f"
        switch unit {
            case .celsius:
                return (String(format: format, temperature), LocalizableString.celsiusSymbol.localized)
            case .fahrenheit:
                let value = shouldConvert ? celsiusToFahrenheit(celsius: temperature.rounded(toPlaces: 1)) : temperature
                return (String(format: format, value), LocalizableString.fahrenheitSymbol.localized)
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
                windSpeed = shouldConvert ? msToKmh(ms: windSpeed) : windSpeed
                windUnit = UnitConstants.KILOMETERS_PER_HOUR
            case .milesPerHour:
                windSpeed = shouldConvert ? msToMph(ms: windSpeed) : windSpeed
                windUnit = UnitConstants.MILES_PER_HOUR
            case .metersPerSecond:
                windUnit = UnitConstants.METERS_PER_SECOND
            case .knots:
                windSpeed = shouldConvert ? msToKnots(ms: windSpeed) : windSpeed
                windUnit = UnitConstants.KNOTS
            case .beaufort:
                windSpeed = shouldConvert ? Double(msToBeaufort(ms: windSpeed)) : windSpeed
                windUnit = UnitConstants.BEAUFORT
				showDecimals = false
        }

        var windDirectionString = "\(windDirection ?? 0)°"
        if directionUnit == .cardinal {
            windDirectionString = degreesToCardinal(value: windDirection ?? 0)
        }

		let convertedValue = windSpeed.rounded(toPlaces: 1)
		let convertedValueStr = showDecimals ? "\(convertedValue)" : "\(Int(convertedValue))"
        return ("\(convertedValueStr)", "\(windUnit) \(includeDirection ? windDirectionString : "")".trimWhiteSpaces())
    }

    /// The text components of the UV. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Returns: A tuple with the text components eg. ("2", "")
    func getUVLiterals(value: Int?) -> WeatherValueLiterals {
        let value = "\(value ?? 0)"
        let unit = ""
        return (value, unit)
    }

    /// The text components of the solar radiation. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Returns: A tuple with the text components eg. ("12.2", "W/m2")
    func getSolarRadiationLiterals(value: Double?) -> WeatherValueLiterals {
        ("\(value?.rounded(toPlaces: 1) ?? 0.0)", UnitConstants.WATTS_PER_SQR)
    }

    /// The text components of the precipitation value. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Parameter unit: The requested unit
    /// - Returns:  tuple with the text components eg. ("5.0", "mm/h")
    func getPrecipitationLiterals(value: Double?, unit: PrecipitationUnitsEnum) -> WeatherValueLiterals {
        switch unit {
            case .millimeters:
                return ("\(value?.rounded(toPlaces: 1) ?? Double.nan)", UnitConstants.MILLIMETERS_PER_HOUR)
            case .inches:
                let convertedValue = (shouldConvert ? millimetersToInches(mm: value ?? Double.nan) : value ?? Double.nan).rounded(toPlaces: 2)
                return ("\(convertedValue)", UnitConstants.INCHES_PER_HOUR)
        }
    }

    /// The text components of the precipitation accumulated value. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Parameter unit: The requested unit
    /// - Returns:  tuple with the text components eg. ("5.0", "mm")
    func getPrecipitationAccumulatedLiterals(from value: Double?, unit: PrecipitationUnitsEnum) -> WeatherValueLiterals? {
        switch unit {
            case .millimeters:
                return ("\((value ?? 0.0).rounded(toPlaces: 1))", UnitConstants.MILLIMETERS)
            case .inches:
                let convertedValue = (shouldConvert ? millimetersToInches(mm: value ?? 0.0) : value ?? 0.0).rounded(toPlaces: 2)
                return ("\(convertedValue)", UnitConstants.INCHES)
        }
    }

    /// The text components of the precipitation probability. (value, unit)
    /// - Parameter value: The value to generate the formatted value
    /// - Returns: A tuple with the text components eg. ("12", "%")
    func getPrecipitationProbabilityLiterals(value: Double?) -> WeatherValueLiterals {
        ("\(Int(value?.rounded(toPlaces: 0) ?? 0))", UnitConstants.PERCENT)
    }
}

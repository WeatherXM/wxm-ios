//
//  WeatherUnitFormatter.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 1/9/22.
//

import Toolkit

public struct WeatherUnitFormatter {
    private let EmptyValue = "-"
    private let PerHourValue = "/h"
    private let userDefaultsRepository: UserDefaultsRepository
    private let unitConverter: UnitsConverter

    private let DecimalsPrecipitationInches = 2
    private let DecimalsPrecipitationMillimeters = 1
    private let DecimalsPressureInHg = 2
    private let DecimalsPressureHpa = 1

    public init(userDefaultsRepository: UserDefaultsRepository, unitConverter: UnitsConverter) {
        self.userDefaultsRepository = userDefaultsRepository
        self.unitConverter = unitConverter
    }

    public func getFormattedWindDirection(value: Int) -> String {
        let defaultUnit = WindChartConstants.CARDINAL
        if let unitProtocol = userDefaultsRepository.readWeatherUnit(key: UserDefaults.WeatherUnitKey.windDirection.rawValue) as? WindDirectionUnitsEnum {
            switch unitProtocol {
            case .cardinal:
                return unitConverter.degreesToCardinal(value: value)
            case .degrees:
                return "\(value)°"
            }
        }
        return "\(value)\(defaultUnit)"
    }

    func convertTemp(value: Double, decimals: Int = 0) -> Double {
        guard let unit = userDefaultsRepository.readWeatherUnit(key: UserDefaults.WeatherUnitKey.temperature.rawValue) as? TemperatureUnitsEnum else {
            return .nan
        }

        var valueToReturn: Double
        switch unit {
        case .celcius:
            valueToReturn = value
        case .fahrenheit:
            valueToReturn = unitConverter.celsiusToFahrenheit(celsius: value)
        }

        if decimals == 0 {
            valueToReturn = roundToInt(value: valueToReturn)
        } else {
            valueToReturn = roundToDecimals(value: valueToReturn)
        }
        return valueToReturn
    }

    func convertPrecipitation(value: Double) -> Double {
        guard let unit = userDefaultsRepository.readWeatherUnit(key: UserDefaults.WeatherUnitKey.precipitation.rawValue) as? PrecipitationUnitsEnum else {
            return .nan
        }
        var valueToReturn: Double
        switch unit {
        case .millimeters:
            valueToReturn = value
            valueToReturn = roundToDecimals(value: valueToReturn)
        case .inches:
            valueToReturn = unitConverter.millimetersToInches(mm: value)
            valueToReturn = roundToDecimals(value: valueToReturn, decimals: 2)
        }

        return valueToReturn
    }

    func convertWindSpeed(value: Double?) -> Double? {
        guard let value = value else {
            return nil
        }

        guard let unit = userDefaultsRepository.readWeatherUnit(key: UserDefaults.WeatherUnitKey.windSpeed.rawValue) as? WindSpeedUnitsEnum else {
            return .nan
        }
        var valueToReturn: Double

        switch unit {
        case .kilometersPerHour:
            valueToReturn = unitConverter.msToKmh(ms: value)
            valueToReturn = roundToDecimals(value: valueToReturn)
        case .milesPerHour:
            valueToReturn = unitConverter.msToMph(ms: value)
            valueToReturn = roundToDecimals(value: valueToReturn)
        case .metersPerSecond:
            valueToReturn = roundToDecimals(value: value)
        case .knots:
            valueToReturn = unitConverter.msToKnots(ms: value)
            valueToReturn = roundToDecimals(value: valueToReturn)
        case .beaufort:
            valueToReturn = Double(unitConverter.msToBeaufort(ms: value))
        }

        return valueToReturn
    }

    func convertPressure(value: Double) -> Double {
        guard let unit = userDefaultsRepository.readWeatherUnit(key: UserDefaults.WeatherUnitKey.pressure.rawValue) as? PressureUnitsEnum else {
            return .nan
        }
        var valueToReturn: Double

        switch unit {
        case .hectopascal:
            valueToReturn = roundToDecimals(value: value)
        case .inchOfMercury:
            valueToReturn = unitConverter.hpaToInHg(hpa: value)
            valueToReturn = roundToDecimals(value: valueToReturn, decimals: 2)
        }
        return valueToReturn
    }

    public func getPreferredUnit(key: String, defaultUnit: String) -> String {
        if let savedUnit = userDefaultsRepository.readWeatherUnit(key: key)?.unit {
            return savedUnit
        }
        return defaultUnit
    }

    func getPrecipitationPreferredUnit(isPrecipRate: Bool) -> String {
        let key = UserDefaults.WeatherUnitKey.precipitation.rawValue
        if let unitProtocol = userDefaultsRepository.readWeatherUnit(key: key) as? PrecipitationUnitsEnum {
            if isPrecipRate {
                return unitProtocol.unit + PerHourValue
            } else {
                return unitProtocol.unit
            }
        }
        return EmptyValue
    }

    public func getDecimalsPrecipitation() -> Int {
        if let unitProtocol = userDefaultsRepository.readWeatherUnit(key: UserDefaults.WeatherUnitKey.precipitation.rawValue) as? PrecipitationUnitsEnum {
            switch unitProtocol {
            case .millimeters:
                return DecimalsPrecipitationMillimeters
            case .inches:
                return DecimalsPrecipitationInches
            }
        }
        return .zero
    }

    public func getDecimalsPressure() -> Int {
        if let unitProtocol = userDefaultsRepository.readWeatherUnit(key: UserDefaults.WeatherUnitKey.pressure.rawValue) as? PressureUnitsEnum {
            switch unitProtocol {
            case .hectopascal:
                return DecimalsPressureHpa
            case .inchOfMercury:
                return DecimalsPressureInHg
            }
        }
        return .zero
    }

    private func roundToDecimals(value: Double, decimals: Int = 1) -> Double {
        return value.rounded(toPlaces: decimals)
    }

    private func roundToInt(value: Double) -> Double {
        return round(value)
    }
}

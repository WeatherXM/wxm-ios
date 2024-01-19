//
//  WeatherUnitsConverter.swift
//  wxm-ios
//
//  Created by Lampros Zouloumis on 1/9/22.
//

import Toolkit
import DomainLayer

public struct WeatherUnitsConverter {
    private let userDefaultsRepository: UserDefaultsRepository
    private let unitConverter: UnitsConverter

    init(userDefaultsRepository: UserDefaultsRepository, unitConverter: UnitsConverter) {
        self.userDefaultsRepository = userDefaultsRepository
        self.unitConverter = unitConverter
    }

    func convertTemp(value: Double, decimals: Int = 0) -> Double {
        guard let unit = userDefaultsRepository.readWeatherUnit(key: UserDefaults.WeatherUnitKey.temperature.rawValue) as? TemperatureUnitsEnum else {
            return .nan
        }

        var valueToReturn: Double
        switch unit {
            case .celsius:
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

    private func roundToDecimals(value: Double, decimals: Int = 1) -> Double {
        return value.rounded(toPlaces: decimals)
    }

    private func roundToInt(value: Double) -> Double {
        return round(value)
    }
}

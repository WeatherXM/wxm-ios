//
//  UnitsEnum.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 1/9/22.
//

import Foundation
import Toolkit

public protocol UnitsProtocol {
    var key: String { get }
    var value: String { get }
    var analyticsValue: ParameterValue { get }
}

public enum TemperatureUnitsEnum: String, CaseIterable, UnitsProtocol {
    case celsius, fahrenheit

    public var key: String {
        UserDefaults.WeatherUnitKey.temperature.rawValue
    }

    public var value: String {
        return rawValue
    }

    public var analyticsValue: ParameterValue {
        switch self {
            case .celsius:
                return .celsius
            case .fahrenheit:
                return .fahrenheit
        }
    }
}

public enum PrecipitationUnitsEnum: String, CaseIterable, UnitsProtocol {
    case millimeters, inches

    public var key: String {
        UserDefaults.WeatherUnitKey.precipitation.rawValue
    }

    public var value: String {
        rawValue
    }

    public var analyticsValue: ParameterValue {
        switch self {
            case .millimeters:
                return .millimeters
            case .inches:
                return .inches
        }
    }
}

public enum WindSpeedUnitsEnum: String, CaseIterable, UnitsProtocol {
    case kilometersPerHour, milesPerHour, metersPerSecond, knots, beaufort

    public var key: String {
        UserDefaults.WeatherUnitKey.windSpeed.rawValue
    }

    public var value: String {
        rawValue
    }

    public var analyticsValue: ParameterValue {
        switch self {
            case .kilometersPerHour:
                return .kmPerHour
            case .milesPerHour:
                return .milesPerHour
            case .metersPerSecond:
                return .metersPerSecond
            case .knots:
                return .knots
            case .beaufort:
                return .beaufort
        }
    }
}

public enum WindDirectionUnitsEnum: String, CaseIterable, UnitsProtocol {
    case cardinal, degrees

    public var key: String {
        UserDefaults.WeatherUnitKey.windDirection.rawValue
    }

    public var value: String {
        rawValue
    }

    public var analyticsValue: ParameterValue {
        switch self {
            case .cardinal:
                return .cardinal
            case .degrees:
                return .degrees
        }
    }
}

public enum PressureUnitsEnum: String, CaseIterable, UnitsProtocol {
    case hectopascal, inchOfMercury

    public var key: String {
        UserDefaults.WeatherUnitKey.pressure.rawValue
    }

    public var value: String {
        rawValue
    }

    public var analyticsValue: ParameterValue {
        switch self {
            case .hectopascal:
                return .hectopascal
            case .inchOfMercury:
                return .inchOfMercury
        }
    }
}

public struct UnitsObjectFactory {
	public init() {}
	
	public func spawn(from rawValue: String) -> UnitsProtocol? {
		if let temperatureUnitsProtocol = TemperatureUnitsEnum(rawValue: rawValue) {
			return temperatureUnitsProtocol
		} else if let precipitationUnitsProtocol = PrecipitationUnitsEnum(rawValue: rawValue) {
			return precipitationUnitsProtocol
		} else if let windSpeedUnitsProtocol = WindSpeedUnitsEnum(rawValue: rawValue) {
			return windSpeedUnitsProtocol
		} else if let windDirectionUnitsProtocol = WindDirectionUnitsEnum(rawValue: rawValue) {
			return windDirectionUnitsProtocol
		} else if let pressureUnitsProtocol = PressureUnitsEnum(rawValue: rawValue) {
			return pressureUnitsProtocol
		}
		return nil
	}

	public func spawnDefault(from key: String) -> UnitsProtocol? {
		switch UserDefaults.WeatherUnitKey(rawValue: key) {
			case .temperature:
				return TemperatureUnitsEnum.celsius
			case .precipitation:
				return PrecipitationUnitsEnum.millimeters
			case .windSpeed:
				return WindSpeedUnitsEnum.kilometersPerHour
			case .windDirection:
				return WindDirectionUnitsEnum.cardinal
			case .pressure:
				return PressureUnitsEnum.hectopascal
			default:
				return nil
		}
	}
}

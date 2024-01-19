//
//  UnitConverter.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 31/8/22.
//

public struct UnitsConverter {
    public init() {}

    private let CardinalValues: [String] = [
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW",
    ]

    public func celsiusToFahrenheit(celsius: Double) -> Double {
        return celsius * 9 / 5 + 32
    }

    public func millimetersToInches(mm: Double) -> Double {
        return mm / 25.4
    }

    public func hpaToInHg(hpa: Double) -> Double {
        return hpa * 0.02953
    }

    public func msToKmh(ms: Double) -> Double {
        return ms * 3.6
    }

    public func msToMph(ms: Double) -> Double {
        return ms * 2.237
    }

    public func msToKnots(ms: Double) -> Double {
        return ms * 1.944
    }

    public func msToBeaufort(ms: Double) -> Int {
        if ms < 0.2 {
            return 0
        } else if ms < 1.5 {
            return 1
        } else if ms < 3.3 {
            return 2
        } else if ms < 5.4 {
            return 3
        } else if ms < 7.9 {
            return 4
        } else if ms < 10.7 {
            return 5
        } else if ms < 13.8 {
            return 6
        } else if ms < 17.1 {
            return 7
        } else if ms < 20.7 {
            return 8
        } else if ms < 24.4 {
            return 9
        } else if ms < 28.4 {
            return 10
        } else if ms < 32.6 {
            return 11
        } else {
            return 12
        }
    }

    public func degreesToCardinal(value: Int) -> String {
        CardinalValues[safe: getIndexOfCardinal(value: value)] ?? "-"
    }

    public func getIndexOfCardinal(value: Int) -> Int {
        let normalized = Int(floor((Double(value) / 22.5) + 0.5))
        return normalized % 16
    }
}

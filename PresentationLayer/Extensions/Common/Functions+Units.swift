//
//  Functions+Units.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 6/9/22.
//

import Foundation

var cardinalValues: [String] {
    [
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
    ]
}

func celsiusToFahrenheit(celsius: Double) -> Double {
    return celsius * 9 / 5 + 32
}

func millimetersToInches(mm: Double) -> Double {
    return mm / 25.4
}

func hpaToInHg(hpa: Double) -> Double {
    return hpa * 0.02953
}

func msToKmh(ms: Double) -> Double {
    return ms * 3.6
}

func msToMph(ms: Double) -> Double {
    return ms * 2.237
}

func msToKnots(ms: Double) -> Double {
    return ms * 1.944
}

func msToBeaufort(ms: Double) -> Int {
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

func degreesToCardinal(value: Int) -> String {
    cardinalValues[safe: getIndexOfCardinal(value: value)] ?? "-"
}

func getIndexOfCardinal(value: Int) -> Int {
    let normalized = Int(floor((Double(value) / 22.5) + 0.5))
    return normalized % 16
}

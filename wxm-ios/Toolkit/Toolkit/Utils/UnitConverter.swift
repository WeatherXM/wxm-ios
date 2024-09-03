//
//  UnitConverter.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 31/8/22.
//

public struct UnitsConverter {
    public init() {}

    private let cardinalValues: [String] = [
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
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
		switch ms {
			case _ where ms < 0.2:
				return 0
			case _ where ms < 0.2:
				return 0
			case _ where ms < 1.5:
				return 1
			case _ where ms < 3.3:
				return 2
			case _ where ms < 5.4:
				return 3
			case _ where ms < 7.9:
				return 4
			case _ where ms < 10.7:
				return 5
			case _ where ms < 13.8:
				return 6
			case _ where ms < 17.1:
				return 7
			case _ where ms < 20.7:
				return 8
			case _ where ms < 24.4:
				return 9
			case _ where ms < 28.4:
				return 10
			case _ where ms < 32.6:
				return 11
			default:
				return 12
		}
	}

    public func degreesToCardinal(value: Int) -> String {
        cardinalValues[safe: getIndexOfCardinal(value: value)] ?? "-"
    }

    public func getIndexOfCardinal(value: Int) -> Int {
		guard value >= 0 else {
			return -1
		}

        let normalized = Int(floor((Double(value) / 22.5) + 0.5))
        return normalized % 16
    }
}

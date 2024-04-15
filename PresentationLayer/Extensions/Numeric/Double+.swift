//
//  Double+.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 21/6/22.
//

import Foundation
import DomainLayer
// https://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }

    var intValueRounded: Int {
        var roundedValue = self
        roundedValue.round(.toNearestOrAwayFromZero)
        return Int(roundedValue)
    }

    var roundedToken: Double {
        let behavior = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        return NSDecimalNumber(value: self).rounding(accordingToBehavior: behavior).doubleValue
    }

	var toWXMTokenPrecisionString: String {
		toPrecisionString(minDecimals: 2, precision: 4)
	}

	func toPrecisionString(minDecimals: Int = 0, precision: Int) -> String {
		return formatted(.number.rounded(rule: .up).precision(.fractionLength(minDecimals...precision)))
	}

    func toTemeratureUnit(_ unit: TemperatureUnitsEnum) -> Double {
        switch unit {
            case .celsius:
                return self
            case .fahrenheit:
                let value = celsiusToFahrenheit(celsius: self)
                return value
        }
    }

	func toTemeratureString(for unit: TemperatureUnitsEnum, decimals: Int = 0) -> String {
        let value = toTemeratureUnit(unit).rounded(toPlaces: decimals)

		let formatter = NumberFormatter()
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = decimals
		formatter.numberStyle = .decimal
		let valueStr = formatter.string(for: value) ?? ""
        switch unit {
            case .celsius:
                return "\(valueStr)\(LocalizableString.celsiusSymbol.localized)"
            case .fahrenheit:
                return "\(valueStr)\(LocalizableString.fahrenheitSymbol.localized)"
        }
    }
}

//
//  Double+.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 21/6/22.
//

import Foundation
import DomainLayer
import Toolkit

extension Double {

    func toTemeratureUnit(_ unit: TemperatureUnitsEnum) -> Double {
        switch unit {
            case .celsius:
                return self
            case .fahrenheit:
				let value = UnitsConverter().celsiusToFahrenheit(celsius: self)
                return value
        }
    }

	func toTemeratureString(for unit: TemperatureUnitsEnum, decimals: Int = 0) -> String {
        let value = toTemeratureUnit(unit).rounded(toPlaces: decimals)

		let formatter = NumberFormatter()
		formatter.minimumFractionDigits = decimals
		formatter.maximumFractionDigits = decimals
		formatter.roundingMode = .halfUp
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

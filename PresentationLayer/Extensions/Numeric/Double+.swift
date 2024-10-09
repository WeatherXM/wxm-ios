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
		let literals = WeatherFormatter().getTemperatureLiterals(temperature: self, unit: unit, decimals: decimals)
		return "\(literals.value)\(literals.unit)"
    }
}

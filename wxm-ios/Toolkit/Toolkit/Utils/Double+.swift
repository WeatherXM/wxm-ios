//
//  Double+.swift
//  Toolkit
//
//  Created by Pantelis Giazitsis on 22/7/24.
//

import Foundation

public extension Double {
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
		toPrecisionString(minDecimals: 2, precision: 2)
	}
	
	func toPrecisionString(minDecimals: Int = 0, precision: Int) -> String {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = precision
		formatter.minimumFractionDigits = minDecimals
		formatter.numberStyle = .decimal
		formatter.roundingMode = .halfUp
		return formatter.string(from: self as NSNumber) ?? "-"
	}
}

infix operator ~==
public extension FloatingPoint {
	static func ~== (lhs: Self, rhs: Self) -> Bool {
		lhs == rhs || lhs.nextDown == rhs || lhs.nextUp == rhs
	}
}

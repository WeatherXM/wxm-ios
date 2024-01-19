//
//  CustomYAxisFormatter.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 25/8/22.
//

import Charts
import Foundation

public class CustomYAxisFormatter: AxisValueFormatter {
    private let weatherUnit: String
    private let decimals: Int

    public init(weatherUnit: String, decimals: Int = 0) {
        self.weatherUnit = weatherUnit
        self.decimals = decimals
    }

    public func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
        var returnedStringDecimal = ""
        var returnedStringInt = ""

        if weatherUnit == "%" || weatherUnit == "°C" || weatherUnit == "°F" {
            returnedStringDecimal = String(format: "%.\(decimals)f\(weatherUnit)", value)
            returnedStringInt = "\(Int(round(value)))\(weatherUnit)"

        } else {
            returnedStringDecimal = String(format: "%.\(decimals)f \(weatherUnit)", value)
            returnedStringInt = "\(Int(round(value))) \(weatherUnit)"
        }

        if decimals > 0 {
            return returnedStringDecimal
        }
        return returnedStringInt
    }
}

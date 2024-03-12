//
//  YAxisValueFormatter.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 22/8/23.
//

import Foundation
import Charts
import DomainLayer

class YAxisValueFormatter: AxisValueFormatter {

    let weatherField: WeatherField
    let handleSidePadding: Bool
    private let mainVM = MainScreenViewModel.shared
    private let maxCharsCount = 4
    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    init(weatherField: WeatherField, handleSidePadding: Bool) {
        self.weatherField = weatherField
        self.handleSidePadding = handleSidePadding
    }

    func stringForValue(_ value: Double, axis: Charts.AxisBase?) -> String {
        var valueStr = formatter.string(from: NSNumber(value: value)) ?? ""
        if valueStr.count > 4 {
            valueStr = value.toCompactDecimaFormat ?? ""
        }

        let fixedStr = fixValueString(str: valueStr)
        return  fixedStr
    }
}

private extension YAxisValueFormatter {
    func fixValueString(str: String) -> String {
        guard handleSidePadding else {
            return str
        }

        var fixedStr = str
        while fixedStr.count < maxCharsCount {
            fixedStr = " " + fixedStr
        }

        return fixedStr
    }
}

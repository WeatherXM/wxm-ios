//
//  WeatherChartDataModel.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 9/5/23.
//

import Charts
import DomainLayer

struct WeatherChartDataModel {
    let weatherField: WeatherField
    var timestamps: [String]
    var entries: [ChartDataEntry]

    public func isNilOrEmpty() -> Bool {
        return timestamps.isEmpty && entries.isEmpty
    }
}

extension WeatherChartDataModel {
    static func mock(type: WeatherField = .temperature,
                     timestamps: [String] = ["0", "1", "2"],
                     dataEntries: [ChartDataEntry] = [ChartDataEntry(x: 0.0, y: 1.0),
                                                      ChartDataEntry(x: 1.0, y: 2.5),
                                                      ChartDataEntry(x: 2.0, y: 4.0)]) -> WeatherChartDataModel {
        return WeatherChartDataModel(weatherField: type,
                              timestamps: timestamps,
                              entries: dataEntries)
    }
}

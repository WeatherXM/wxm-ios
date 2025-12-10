//
//  WeatherChartModels.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 9/5/23.
//

import Foundation
import DomainLayer

public struct WeatherChartModels {
    /// Used to indicate ONLY the day of the chart
    var markDate: Date?
    var tz: String?
    var dataModels: [WeatherField: WeatherChartDataModel]

    var availableChartTypes: [ForecastChartType] {
        ForecastChartType.allCases.filter { type in
            type.weatherFields.reduce(false) { $0 || (dataModels[$1]?.entries.isEmpty == false) }
        }
    }

    public var dateStringRepresentation: String? {
        markDate?.getDateStringRepresentation()
    }

    func isEmpty() -> Bool {
		dataModels.allSatisfy { $0.value.isNilOrEmpty() }
    }
}

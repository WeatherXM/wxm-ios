//
//  HistoryChartModels.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 9/5/23.
//

import Foundation
import DomainLayer

public struct HistoryChartModels {
    /// Used to indicate ONLY the day of the chart
    var markDate: Date?
    var tz: String?
    var dataModels: [WeatherField: WeatherChartDataModel]

    public var dateStringRepresentation: String? {
        markDate?.getDateStringRepresentation()
    }

    func isEmpty() -> Bool {
		dataModels.allSatisfy { $0.value.isNilOrEmpty() }
    }
}

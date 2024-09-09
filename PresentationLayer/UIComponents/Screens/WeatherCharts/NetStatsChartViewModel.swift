//
//  NetStatsChartViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 12/6/23.
//

import Foundation
import DGCharts

struct NetStatsChartViewModel {
    let entries: [ChartDataEntry]
}

extension NetStatsChartViewModel {
    static func mock(dataEntries: [ChartDataEntry] = [ChartDataEntry(x: 0.0, y: 1.0),
                                                      ChartDataEntry(x: 1.0, y: 2.5),
                                                      ChartDataEntry(x: 2.0, y: 4.0)]) -> NetStatsChartViewModel {
        return NetStatsChartViewModel(entries: dataEntries)
    }
}

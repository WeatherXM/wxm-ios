//
//  XAxisValueFormatter.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 25/8/22.
//

import Charts

public class ChartXAxisValueFormatter: AxisValueFormatter {
    private let times: [String]
    public init(times: [String]) {
        self.times = times
    }

    public func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
        return times[safe: Int(value)] ?? String(value)
    }
}

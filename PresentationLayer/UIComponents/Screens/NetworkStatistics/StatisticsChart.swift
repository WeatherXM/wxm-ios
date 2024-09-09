//
//  StatisticsChart.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/6/23.
//

import Foundation
import DGCharts
import SwiftUI

struct StatisticsChart: UIViewRepresentable {
    let chartDataModel: NetStatsChartViewModel

    func makeUIView(context _: Context) -> StatisticsChartView {
        let chartView = StatisticsChartView()
        chartView.initializeChart(dataModel: chartDataModel)

        return chartView
    }

    func updateUIView(_ uiView: StatisticsChartView, context _: Context) {
    }
}

class StatisticsChartView: LineChartView {
    func initializeChart(dataModel: NetStatsChartViewModel) {
        configureDefault()
        let dataSet = LineChartDataSet(entries: dataModel.entries)

        dataSet.circleRadius = 1.0
        dataSet.setCircleColor(UIColor(colorEnum: .chartPrimary))
        dataSet.drawCircleHoleEnabled = false
        dataSet.lineWidth = 2.0
        dataSet.setColor(UIColor(colorEnum: .chartPrimary))
        dataSet.mode = .cubicBezier
        dataSet.highlightEnabled = false

        let lineData = LineChartData(dataSets: [dataSet])
        lineData.setDrawValues(false)
        data = lineData
        notifyDataSetChanged()

        animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
    }
}

extension StatisticsChartView {
    func configureDefault() {
        legend.enabled = false
        scaleYEnabled = false
        scaleXEnabled = false

        minOffset = 2.0

        leftAxis.granularityEnabled = true
        leftAxis.enabled = false

        rightAxis.enabled = false

        xAxis.enabled = false

        dragYEnabled = false
    }
}

struct Previews_StatisticsChart_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsChart(chartDataModel: .mock())
            .padding()
    }
}

//
//  WXMLineChart.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/5/23.
//

import Foundation
import SwiftUI
import Charts
import DomainLayer

enum WeatherChartsConstants {
    static let LINE_WIDTH: CGFloat = 2.0
    static let POINT_SIZE: CGFloat = 2.0
    static let X_AXIS_DEFAULT_TIME_GRANULARITY: Double = 3.0
    static let X_AXIS_GRANULARITY_1_HOUR: Double = 1.0
    static let VALID_DATASET_LABEL = "validDataset"

    /* Colors */
    static let GRID_COLOR = UIColor(colorEnum: .bg)
    static let legendColors: [ColorEnum] = [.primary, .chartSecondaryLine]

}

struct WeatherLineChart: UIViewRepresentable {
    let type: any ChartCardProtocol
    let chartData: [WeatherChartDataModel]
    let delegate: ChartDelegate

    func makeUIView(context _: Context) -> WeatherLineChartView {
        let chartView = WeatherLineChartView()
        chartView.delegate = delegate
        chartView.initializeWXMChart(type: type, chartData: chartData)

        return chartView
    }

    func updateUIView(_ uiView: WeatherLineChartView, context _: Context) {
        guard let selectedIndex = delegate.selectedIndex,
              let dataSetIndex = uiView.lineData?.dataSets.firstIndex(where: { dataSet in
                  let label = dataSet.label
                  let entries = dataSet.entriesForXValue(Double(selectedIndex))
                  return label == WeatherChartsConstants.VALID_DATASET_LABEL && !entries.isEmpty
              }) else {
            return
        }

        uiView.highlightValue(x: Double(selectedIndex), dataSetIndex: dataSetIndex, callDelegate: false)
    }
}

class WeatherLineChartView: LineChartView {
    func initializeWXMChart(type: any ChartCardProtocol, chartData: [WeatherChartDataModel]) {
        configureDefault(chartData: chartData)
        configure(for: type, chartData: chartData)
        notifyDataSetChanged()
    }
}

private extension WeatherLineChartView {

    func configureDefault(chartData: [WeatherChartDataModel]) {
        legend.enabled = false
        lineData?.setDrawValues(false)
        scaleYEnabled = false
        dragYEnabled = false

        leftAxis.granularityEnabled = true
        leftAxis.resetCustomAxisMin()
        leftAxis.resetCustomAxisMax()
        leftAxis.zeroLineWidth = 1.0
        leftAxis.zeroLineColor = UIColor(colorEnum: .darkGrey)
        leftAxis.drawZeroLineEnabled = true
        leftAxis.labelCount = 4

        rightAxis.granularityEnabled = true
        rightAxis.resetCustomAxisMin()
        rightAxis.resetCustomAxisMax()
        rightAxis.labelCount = 4

        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = false
        xAxis.granularity = WeatherChartsConstants.X_AXIS_DEFAULT_TIME_GRANULARITY
        xAxis.avoidFirstLastClippingEnabled = true
        let allTimestamps = chartData.flatMap { $0.timestamps }.withNoDuplicates
        xAxis.valueFormatter = ChartXAxisValueFormatter(times: allTimestamps)

        // Axis Colors
        leftAxis.gridColor = WeatherChartsConstants.GRID_COLOR
        rightAxis.gridColor = WeatherChartsConstants.GRID_COLOR
        rightAxis.drawGridLinesEnabled = false
        xAxis.gridColor = WeatherChartsConstants.GRID_COLOR
    }

    func configure(for type: any ChartCardProtocol, chartData: [WeatherChartDataModel]) {
        var dataSets: [LineChartDataSet] = []
        for (index, element) in chartData.enumerated() {
            let datasetsTuple = generateDataSets(from: element.entries,
                                                 color: WeatherChartsConstants.legendColors[safe: index] ?? .primary,
                                                 weatherField: element.weatherField,
                                                 axisDependency: type.getAxisDependecy(for: element.weatherField))

            // Insert at beggining to render the first model
            // on top of the others
            dataSets.insert(contentsOf: datasetsTuple.validDataSets, at: 0)
            dataSets.insert(contentsOf: datasetsTuple.emptyDataSets, at: 0)
        }

        adjustAxisToPreventLabelsFromHiding(dataSets: dataSets.filter { $0.label == WeatherChartsConstants.VALID_DATASET_LABEL })

        let lineData = LineChartData(dataSets: dataSets)
        lineData.setValueTextColor(.clear)
        data = lineData

        adjustAxisToPreventLabelsFromHiding(data: lineData)

        if let firstWeatherField = type.weatherFields.first {
            leftAxis.valueFormatter = YAxisValueFormatter(weatherField: firstWeatherField, handleSidePadding: true)
            leftAxis.granularity = firstWeatherField.granularity(for: lineData)
        }

        if let lastWeatherField = type.weatherFields.last {
            rightAxis.valueFormatter = YAxisValueFormatter(weatherField: lastWeatherField, handleSidePadding: false)
            rightAxis.granularity = lastWeatherField.granularity(for: lineData)
        }
        
        rightAxis.enabled = type.isRightAxisEnabled

		type.configureAxis(leftAxis: leftAxis, rightAxis: rightAxis, for: lineData)
    }

    func configureDataSet(dataSet: LineChartDataSet, for weatherField: WeatherField) {
        switch weatherField {
            case .temperature:
                break
            case .feelsLike:
                break
            case .humidity:
                break
            case .wind:
                break
			case .windDirection:
				break
            case .precipitation:
                dataSet.drawCirclesEnabled = dataSet.entries.count == 1
                dataSet.mode = .stepped
            case .dailyPrecipitation:
                dataSet.drawCirclesEnabled = dataSet.entries.count == 1
                dataSet.lineWidth = 0.0
                dataSet.mode = .horizontalBezier
                dataSet.drawFilledEnabled = true
            case .windGust:
                break
            case .pressure:
                break
            case .solarRadiation, .precipitationProbability:
                dataSet.drawCirclesEnabled = dataSet.entries.count == 1
                dataSet.drawFilledEnabled = true
                dataSet.lineWidth = 0.0
                dataSet.mode = .horizontalBezier
			case .illuminance:
				break
            case .dewPoint:
                break
            case .uv:
                dataSet.drawCirclesEnabled = dataSet.entries.count == 1
                dataSet.mode = .stepped
        }
    }

    func adjustAxisToPreventLabelsFromHiding(dataSets: [LineChartDataSet]) {
        #warning("TBD: Since the y axis labels are hidden is this snippet necessary")
        /*
         * If max - min < 2 that means that the values are probably too close together.
         * Which causes a bug not showing labels on Y axis because granularity is set 1.
         * So this is a custom fix to add custom minimum and maximum values on the Y Axis
         */
//        let yMax = dataSets.max { $0.yMax < $1.yMax }?.yMax ?? 0.0
//        let yMin = dataSets.min { $0.yMin < $1.yMin }?.yMin ?? 0.0
//        if yMax - yMin < 2 {
//            leftAxis.axisMinimum = yMin - 1
//            leftAxis.axisMaximum = yMax + 1
//        }
    }

    func adjustAxisToPreventLabelsFromHiding(data: LineChartData) {
        let yMax = data.yMax
        let yMin = data.yMin
        if yMax - yMin < 2 {
            leftAxis.axisMinimum = yMin - 1
            leftAxis.axisMaximum = yMax + 1
            rightAxis.axisMinimum = yMin - 1
            rightAxis.axisMaximum = yMax + 1
        }
    }

    func generateDataSets(from entries: [ChartDataEntry],
                          color: ColorEnum,
                          weatherField: WeatherField,
                          axisDependency: YAxis.AxisDependency) -> (validDataSets: [LineChartDataSet], emptyDataSets: [LineChartDataSet]) {
        var validDataSets: [LineChartDataSet] = []
        var emptyDataSets: [LineChartDataSet] = []

        var iterateEntries = entries
        while !iterateEntries.isEmpty {
            let withValues = iterateEntries.remove(while: { !$0.y.isNaN })
            if !withValues.isEmpty {
                let dataSet = LineChartDataSet(entries: withValues, label: WeatherChartsConstants.VALID_DATASET_LABEL)
                dataSet.setDefaultSettings(color: UIColor(colorEnum: color))
                configureDataSet(dataSet: dataSet, for: weatherField)
                dataSet.axisDependency = axisDependency
                validDataSets.append(dataSet)
            }

            let withNoValues = iterateEntries.remove(while: { $0.y.isNaN })
            if !withNoValues.isEmpty {
                let yMax = validDataSets.last?.yMax ?? 0.0
                let emptyEntries = withNoValues.map { ChartDataEntry(x: $0.x, y: yMax) }
                let emptyDataSet = LineChartDataSet(entries: emptyEntries)
                emptyDataSet.setDefaultSettings(color: .clear)
                emptyDataSet.highlightEnabled = false
                emptyDataSet.axisDependency = axisDependency
                emptyDataSets.append(emptyDataSet)
            }
        }

        return (validDataSets, emptyDataSets)
    }
}

private extension LineChartDataSet {
    func setDefaultSettings(color: UIColor = UIColor(colorEnum: .primary)) {
        drawCircleHoleEnabled = false
        circleRadius = WeatherChartsConstants.POINT_SIZE
        lineWidth = WeatherChartsConstants.LINE_WIDTH
        mode = .cubicBezier
        setColor(color)
        setCircleColor(color)
        fillColor = color
        highlightColor = color
        drawHorizontalHighlightIndicatorEnabled = false
        highlightLineWidth = 2.0
        highlightColor = UIColor(colorEnum: .primary)
        highlightLineDashLengths = [4.0]
    }
}

private extension WeatherField {
	func granularity(for lineData: LineChartData) -> Double {
		switch self {
			case .temperature, .feelsLike, .humidity, .wind, .windDirection,
					.precipitationProbability, .windGust, .solarRadiation, .illuminance, .dewPoint, .uv:
				return 1.0
			case .precipitation, .dailyPrecipitation:
				let isInchesSelected = WeatherUnitsManager.default.precipitationUnit == .inches
				return isInchesSelected ? 0.01 : 0.1
			case .pressure:
				let isInHg = WeatherUnitsManager.default.pressureUnit == .inchOfMercury
				let yMin = lineData.yMin
				let yMax = lineData.yMax
				let shouldChangeGranularity = isInHg && (yMax - yMin < 2.0)
				return isInHg ? 0.01 : 1.0
		}
	}
}

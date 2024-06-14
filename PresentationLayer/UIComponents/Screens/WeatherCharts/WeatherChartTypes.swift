//
//  ChartTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/4/24.
//

import Foundation
import DomainLayer
import Charts

protocol ChartCardProtocol: CaseIterable, CustomStringConvertible {
	var icon: AssetEnum { get }
	var weatherFields: [WeatherField] { get }
	var scrollId: String { get }
	var isRightAxisEnabled: Bool { get }
	func getAxisDependecy(for weatherField: WeatherField) -> YAxis.AxisDependency
	func configureAxis(leftAxis: YAxis, rightAxis: YAxis, for lineData: LineChartData)
	func legendTitle(for weatherField: WeatherField) -> String
	func highlightTitle(for weatherField: WeatherField) -> String
}


class ChartDelegate: ObservableObject, ChartViewDelegate {
	@Published var selectedIndex: Int?

	func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
		selectedIndex = Int(entry.x)
	}
}

//
//  ChartView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/9/24.
//

import SwiftUI
import Charts

struct ChartDataItem: Identifiable {
	var id: String {
		xVal
	}

	let xVal: String
	let yVal: Double
}

struct ChartView: View {
	let data: [ChartDataItem]

    var body: some View {
		if #available(iOS 16.0, *) {
			ChartAreaView(data: data)
		} else {
			EmptyView()
		}
    }
}


@available(iOS 16.0, *)
private struct ChartAreaView: View {

	let data: [ChartDataItem]
	var body: some View {
		Chart(data) { item in
			LineMark(x: .value("x_val", item.xVal), y: .value("value", item.yVal))
				.foregroundStyle(Color(colorEnum: .chartPrimary))
				.interpolationMethod(.monotone)
		}
		.chartLegend(.hidden)
	}
}

#Preview {
	ChartView(data: [.init(xVal: "Mon", yVal: 3.0),
					 .init(xVal: "Tue", yVal: 4.0),
					 .init(xVal: "Wed", yVal: 14.34234),
					 .init(xVal: "Thu", yVal: 5.45252),
					 .init(xVal: "Fri", yVal: 7.090),
					 .init(xVal: "Sat", yVal: 9.21092),
					 .init(xVal: "Sun", yVal: 12.2132)])
}

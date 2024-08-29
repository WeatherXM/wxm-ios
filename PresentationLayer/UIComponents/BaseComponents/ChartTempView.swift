//
//  ChartTempView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/8/24.
//

import SwiftUI
import Charts

struct Weekday: Identifiable {
	let month: String
	let title: String
	let value: Double

	var id: String {
		title
	}
}

@available(iOS 16.0, *)
struct ChartTempView: View {
	let data: [Weekday] = [.init(month: "June", title: "Monday", value: 1.0),
						   .init(month: "June", title: "Tuesday", value: 1.5),
						   .init(month: "June", title: "Wednesday", value: 3.67),
						   .init(month: "June", title: "Thursday", value: 5.0),
						   .init(month: "June", title: "Friday", value: 2.3),
						   .init(month: "June", title: "Saturday", value: 4.7),
						   .init(month: "June", title: "Sunday", value: 7.0)]

    var body: some View {
		Chart(data) { day in
			Plot {
				AreaMark(x: .value("day", day.title), y: .value("val", day.value), stacking: .standard)
					.foregroundStyle(by: .value("Month", day.month))
					.interpolationMethod(.monotone)
					.position(by: .value("month", day.month))
			}
//			LineMark(x: .value("day", day.title), y: .value("val", day.value), series: .value("day", "da"))
//				.foregroundStyle(.red)
//				.interpolationMethod(.monotone)
//				.symbol(.asterisk)
		}
		.chartLegend(.hidden)
    }
}

#Preview {
	if #available(iOS 16.0, *) {
		return ChartTempView()
			.padding()
	} else {
		return EmptyView()
	}
}

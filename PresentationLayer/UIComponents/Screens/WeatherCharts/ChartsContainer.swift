//
//  ChartContainer.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 6/9/22.
//

import DGCharts
import DomainLayer
import SwiftUI

struct ChartsContainer: View {
    let historyData: WeatherChartModels
	let chartTypes: [any ChartCardProtocol]
    @StateObject var delegate: ChartDelegate

    var body: some View {
        VStack(spacing: CGFloat(.largeSpacing)) {
			ForEach(0..<chartTypes.count, id: \.self) { index in
				let chart = chartTypes[index]
                ChartCardView(type: chart,
                              chartDataModels: chart.weatherFields.compactMap { historyData.dataModels[$0] })
                .environmentObject(delegate)
				.id(chart.scrollId)
            }

            if let timezone = historyData.tz {
                HStack {
                    Text(LocalizableString.timeZoneDisclaimer(timezone).localized)
                        .foregroundColor(Color(colorEnum: .text))
                        .font(.system(size: CGFloat(.caption)))
						.fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(.bottom, CGFloat(.defaultSidePadding))
            }
        }
    }
}

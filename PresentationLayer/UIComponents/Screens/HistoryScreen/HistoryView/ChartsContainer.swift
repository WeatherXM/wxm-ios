//
//  ChartContainer.swift
//  PresentationLayer
//
//  Created by Lampros Zouloumis on 6/9/22.
//

import Charts
import DomainLayer
import SwiftUI

struct ChartsContainer: View {
    let historyData: HistoryChartModels
    @StateObject var delegate: ChartDelegate

    var body: some View {
        VStack(spacing: CGFloat(.mediumSpacing)) {
            ForEach(ChartCardType.allCases, id: \.self) { chart in
                ChartCardView(type: chart,
                              chartDataModels: chart.weatherFields.compactMap { historyData.dataModels[$0] })
                .environmentObject(delegate)
            }

            if let timezone = historyData.tz {
                HStack {
                    Text(LocalizableString.timeZoneDisclaimer(timezone).localized)
                        .foregroundColor(Color(colorEnum: .text))
                        .font(.system(size: CGFloat(.caption)))
                    Spacer()
                }
                .padding(.bottom, CGFloat(.defaultSidePadding))
            }
        }
    }
}

//
//  ChartCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/5/23.
//

import SwiftUI
import Charts

struct ChartCardView: View {
    @EnvironmentObject var delegate: ChartDelegate
    let type: any ChartCardProtocol
    let chartDataModels: [WeatherChartDataModel]

	private let unitsManager: WeatherUnitsManager = .default

    var body: some View {
        VStack(spacing: 0.0) {
            HStack(alignment: .center, spacing: CGFloat(.minimumSpacing)) {
                Image(asset: type.icon)
                    .renderingMode(.template)
                    .foregroundColor(Color(colorEnum: .text))

                Text(type.description)
                    .font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
                    .foregroundColor(Color(colorEnum: .text))
                    .lineLimit(1)
                    .fixedSize()

                Spacer()

                if chartDataModels.count > 1 {
                    legend
                }
            }
            .padding(.horizontal, CGFloat(.defaultSidePadding))
            .padding(.vertical, CGFloat(.smallSidePadding))

            VStack(spacing: CGFloat(.smallSpacing)) {
                HStack {
                    Text(currentValueText)
                        .font(.system(size: CGFloat(.smallFontSize)))
                        .foregroundColor(Color(colorEnum: .darkestBlue))

                    Spacer()
                }
                .WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
                              insideHorizontalPadding: CGFloat(.smallSidePadding),
                              insideVerticalPadding: CGFloat(.minimumPadding),
                              cornerRadius: CGFloat(.buttonCornerRadius))

                WeatherLineChart(type: type, chartData: chartDataModels, delegate: delegate)
                    .frame(height: 160.0)
            }
            .WXMCardStyle()

        }
        .WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
                      insideHorizontalPadding: 0.0,
                      insideVerticalPadding: 0.0)
        .wxmShadow()
    }
}

private extension ChartCardView {
    @ViewBuilder
    var legend: some View {
        HStack(spacing: CGFloat(.smallSpacing)) {
            ForEach(0 ..< chartDataModels.count, id: \.self) { index in
                let model = chartDataModels[index]
                VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
					Text(type.legendTitle(for: model.weatherField))
                        .foregroundColor(Color(colorEnum: .text))
                        .font(.system(size: CGFloat(.caption)))
                        .lineLimit(1)
                    Color(colorEnum: WeatherChartsConstants.legendColors[safe: index] ?? .primary)
                        .frame(width: 44.0, height: 8.0)
                        .cornerRadius(CGFloat(.lightCornerRadius))
                }
            }
        }
    }

    var currentValueText: AttributedString {
        guard let index = delegate.selectedIndex,
              let timestamp = chartDataModels.first?.timestamps[safe: index] else {
            return ""
        }

        let comps: [String] = chartDataModels.map { model in
			let entry = model.entries[safe: index]
			let literals = type.getWeatherLiterals(chartEntry: entry, weatherField: model.weatherField)
            let formattedValue = "\(literals?.value ?? "")\(model.weatherField.shouldHaveSpaceWithUnit ? " " : "")\(literals?.unit ?? "")".trimWhiteSpaces()
			return "\(type.highlightTitle(for: model.weatherField)): **\(formattedValue)**"
        }
        let text = comps.joined(separator: "﹒")

        return "**\(timestamp)**\n\(text)".attributedMarkdown ?? ""
    }
}

struct ChartCardView_Previews: PreviewProvider {
    static var previews: some View {
        let entries = [ChartDataEntry(x: 0.0, y: 19.3),
                       ChartDataEntry(x: 1.0, y: 18.8),
                       ChartDataEntry(x: 2.0, y: 18.3),
                       ChartDataEntry(x: 3.0, y: 17.8),
                       ChartDataEntry(x: 4.0, y: 17.5),
                       ChartDataEntry(x: 5.0, y: 17.6),
                       ChartDataEntry(x: 6.0, y: 18.6),
                       ChartDataEntry(x: 7.0, y: 19.9),
                       ChartDataEntry(x: 8.0, y: 20.8),
                       ChartDataEntry(x: 9.0, y: 21.8),
                       ChartDataEntry(x: 10.0, y: 22.8),
                       ChartDataEntry(x: 11.0, y: 23.6),
                       ChartDataEntry(x: 12.0, y: 24.3),
                       ChartDataEntry(x: 13.0, y: 24.9),
                       ChartDataEntry(x: 14.0, y: 25.5)]

        ChartCardView(type: ChartCardType.temperature,
                      chartDataModels: [WeatherChartDataModel.mock(type: .temperature,
                                                            timestamps: entries.map { "\($0.x.rounded())" },
                                                            dataEntries: entries),
                                        WeatherChartDataModel.mock(type: .feelsLike,
                                                            timestamps: entries.map { "\($0.x.rounded())" },
                                                            dataEntries: entries)])
            .padding()
            .environmentObject(ChartDelegate())
    }
}

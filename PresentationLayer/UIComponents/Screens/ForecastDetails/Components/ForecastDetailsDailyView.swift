//
//  ForecastDetailsDailyView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/4/24.
//

import SwiftUI
import DomainLayer

struct ForecastDetailsDailyView: View {
	let item: Item
	let scrollProxy: ScrollViewProxy?

    var body: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			dailyConditions

			hourlyForecast

			charts
		}
    }
}

extension ForecastDetailsDailyView {
	struct Item {
		let forecast: NetworkDeviceForecastResponse?
		let fieldItems: [ForecastFieldCardView.Item]
		let hourlyItems: [StationForecastMiniCardView.Item]?
		var initialHourlyItemIndex: Int?
		let chartModels: WeatherChartModels?
		weak var chartDelegate: ChartDelegate?
	}
}

private extension ForecastDetailsDailyView {
	@ViewBuilder
	var dailyConditions: some View {
		if let currentForecast = item.forecast {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				HStack {
					Text(LocalizableString.Forecast.dailyConditions.localized)
						.foregroundColor(Color(colorEnum: .darkestBlue))
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))

					Spacer()
				}

				if let item = currentForecast.dailyForecastTemperatureItem {
					ForecastTemperatureCardView(item: item)
						.wxmShadow()
				}

				dailyConditionsFields
			}
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var dailyConditionsFields: some View {
		LazyVGrid(columns: [.init(spacing: CGFloat(.smallToMediumSpacing)), .init()],
				  spacing: CGFloat(.smallToMediumSpacing)) {
			Group {
				ForEach(item.fieldItems, id: \.title) { item in
					Button {
						withAnimation {
							scrollProxy?.scrollTo(item.scrollToGraphType?.scrollId, anchor: .top)
						}
					} label: {
						ForecastFieldCardView(item: item)
					}
				}
				.wxmShadow()
			}
		}
	}

	@ViewBuilder
	var hourlyForecast: some View {
		if let hourlyItems = item.hourlyItems, !hourlyItems.isEmpty {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				HStack {
					Text(LocalizableString.Forecast.hourlyForecast.localized)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .darkestBlue))

					Spacer()
				}

				ScrollViewReader { proxy in
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHStack(spacing: CGFloat(.smallSpacing)) {
							ForEach(0..<hourlyItems.count, id: \.self) { index in
								let item = hourlyItems[index]
								StationForecastMiniCardView(item: item, isSelected: false)
									.wxmShadow()
									.frame(width: 80.0)
									.id(index)
							}
						}
					}
					.onAppear {
						if let index = item.initialHourlyItemIndex {
							proxy.scrollTo(index, anchor: .leading)
						}
					}
				}
			}
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var charts: some View {
		if let chartModels = item.chartModels, let delegate = item.chartDelegate {
			ChartsContainer(historyData: chartModels,
							chartTypes: ForecastChartType.allCases,
							delegate: delegate)
				.id(chartModels.markDate)
		} else {
			EmptyView()
		}
	}
}


#Preview {
	let forecast: NetworkDeviceForecastResponse = .init(tz: "Europe/Athens",
														 date: "",
														 hourly: (0..<24).map {_ in .mockInstance },
														 daily: .mockInstance)
	
	return ForecastDetailsDailyView(item: .init(forecast: forecast,
												fieldItems: [],
												hourlyItems: nil,
												chartModels: nil,
												chartDelegate: nil),
									scrollProxy: nil)
}

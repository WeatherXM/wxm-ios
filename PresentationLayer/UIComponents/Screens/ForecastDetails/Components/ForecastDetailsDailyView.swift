//
//  ForecastDetailsDailyView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/4/24.
//

import SwiftUI
import DomainLayer

struct ForecastDetailsDailyView: View {
	@ObservedObject var viewModel: ForecastDetailsViewModel
	let item: Item
	let scrollProxy: ScrollViewProxy?

    var body: some View {
		VStack(spacing: CGFloat(.largeSpacing)) {
			dailyConditions

			if !viewModel.isLoggedIn {
				joinNetworkView
			}

			hourlyForecast

			charts
		}
    }
}

extension ForecastDetailsDailyView {
	struct Item {
		let temperatureItem: ForecastTemperatureCardView.Item?
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
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack {
				Text(LocalizableString.Forecast.dailyConditions.localized)
					.foregroundColor(Color(colorEnum: .darkestBlue))
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))

				Spacer()
			}

			VStack(spacing: CGFloat(.mediumSpacing)) {
				if let item = item.temperatureItem {
					Button {
						withAnimation {
							scrollProxy?.scrollTo(item.scrollToGraphType?.scrollId, anchor: .top)
						}
					} label: {
						ForecastTemperatureCardView(item: item)
					}
				}

				dailyConditionsFields
			}
			.WXMCardStyle(insideHorizontalPadding: CGFloat(.mediumSidePadding),
						  insideVerticalPadding: CGFloat(.mediumSidePadding))
			.wxmShadow()
		}
	}

	@ViewBuilder
	var dailyConditionsFields: some View {
		LazyVGrid(columns: [.init(), .init(), .init()],
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
						HStack(spacing: CGFloat(.smallSpacing)) {
							ForEach(0..<hourlyItems.count, id: \.self) { index in
								let item = hourlyItems[index]
								StationForecastMiniCardView(item: item, isSelected: false)
									.wxmShadow()
									.frame(width: StationForecastMiniCardView.defaultWidth)
									.id(index)
							}
						}
					}
					.disableScrollClip()
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

	@ViewBuilder
	var joinNetworkView: some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
				Text(LocalizableString.Forecast.joinTheNetwork.localized)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .wxmPrimary))

				Text(LocalizableString.Forecast.joinTheNetworkDescription.localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .text))
					.multilineTextAlignment(.leading)
			}

			Spacer()

			Button {
				viewModel.handleShopNowButtonTap()
			} label: {
				Text(LocalizableString.Forecast.shopNow.localized)
					.padding(.horizontal, CGFloat(.defaultSidePadding))
					.padding(.vertical, CGFloat(.smallToMediumSidePadding))
			}
			.buttonStyle(WXMButtonStyle.filled(fixedSize: true))

		}
		.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint))
		.wxmShadow()
	}
}

#Preview {
	let forecast: NetworkDeviceForecastResponse = .init(tz: "Europe/Athens",
														 date: "",
														 hourly: (0..<24).map {_ in .mockInstance },
														 daily: .mockInstance)
	
	ForecastDetailsDailyView(viewModel: ViewModelsFactory.getForecastDetailsViewModel(configuration: .init(forecasts: [forecast],
																										   selectedforecastIndex: 0,
																										   selectedHour: nil,
																										   device: .mockDevice,
																										   followState: .init(deviceId: "", relation: .owned))),
							 item: .init(temperatureItem: forecast.dailyForecastTemperatureItem(),
										 fieldItems: [],
										 hourlyItems: nil,
										 chartModels: nil,
										 chartDelegate: nil),
							 scrollProxy: nil)
}

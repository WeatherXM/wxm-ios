//
//  ForecastDetailsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import SwiftUI
import DomainLayer

struct ForecastDetailsView: View {
	@StateObject var viewModel: ForecastDetailsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

	var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			ScrollView(showsIndicators: false) {
				VStack(spacing: CGFloat(.largeSpacing)) {
					NavigationTitleView(title: .constant(viewModel.device.displayName),
										subtitle: .constant(viewModel.device.address)) {
						Group {
							if let faIcon = viewModel.followState?.state.FAIcon {
								Text(faIcon.icon.rawValue)
									.font(.fontAwesome(font: faIcon.font, size: CGFloat(.mediumFontSize)))
									.foregroundColor(Color(colorEnum: faIcon.color))
							} else {
								EmptyView()
							}
						}
					}

					dailyForecast

					Group {
						dailyConditions

						hourlyForecast

						charts
					}
					.animation(.easeIn, value: viewModel.selectedForecastIndex)
				}
				.padding(.horizontal, CGFloat(.mediumSidePadding))
			}
		}.onAppear {
			navigationObject.navigationBarColor = Color(.newBG)
		}
	}
}

private extension ForecastDetailsView {
	@ViewBuilder
	var dailyConditions: some View {
		if let currentForecast = viewModel.currentForecast {
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
				ForEach(viewModel.fieldItems, id: \.title) { item in
					ForecastFieldCardView(item: item)
				}
				.wxmShadow()
			}
		}
	}

	@ViewBuilder
	var hourlyForecast: some View {
		let hourlyItems = viewModel.hourlyItems
		if !hourlyItems.isEmpty {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				HStack {
					Text(LocalizableString.Forecast.hourlyForecast.localized)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .darkestBlue))

					Spacer()
				}

				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: CGFloat(.smallSpacing)) {
						ForEach(0..<hourlyItems.count, id: \.self) { index in
							let item = hourlyItems[index]
							StationForecastMiniCardView(item: item, isSelected: false)
								.wxmShadow()
								.frame(width: 80.0)
						}
					}
				}
			}
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var dailyForecast: some View {
		let dailyItems = viewModel.dailyItems
		if !dailyItems.isEmpty {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: CGFloat(.smallSpacing)) {
						ForEach(0..<dailyItems.count, id: \.self) { index in
							let item = dailyItems[index]
							StationForecastMiniCardView(item: item, isSelected: viewModel.selectedForecastIndex == index)
								.wxmShadow()
								.frame(width: 80.0)
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
		if let chartModels = viewModel.chartModels {
			ChartsContainer(historyData: chartModels, 
							chartTypes: ForecastChartType.allCases,
							delegate: viewModel.chartDelegate)
				.id(chartModels.markDate)
		} else {
			EmptyView()
		}
	}
}

#Preview {
	NavigationContainerView {
		let forecasts: [NetworkDeviceForecastResponse] = (0..<6).map { _ in .init(tz: "Europe/Athens", date: "", hourly: (0..<24).map {_ in .mockInstance }, daily: .mockInstance) }
		ForecastDetailsView(viewModel: ViewModelsFactory.getForecastDetailsViewModel(forecasts: forecasts,
																					 device: .mockDevice,
																					 followState: .init(deviceId: "", relation: .owned)))
	}
}

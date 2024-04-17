//
//  ForecastDetailsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import SwiftUI

struct ForecastDetailsView: View {
	@StateObject var viewModel: ForecastDetailsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

	var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			ScrollView(showsIndicators: false) {
				VStack(spacing: CGFloat(.mediumSpacing)) {
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

					dailyConditions

					hourlyForecast
				}.padding(.horizontal, CGFloat(.mediumSidePadding))
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
						ForEach(0..<viewModel.hourlyItems.count, id: \.self) { index in
							let item = viewModel.hourlyItems[index]
							StationForecastMiniCardView(item: item)
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
}

#Preview {
	NavigationContainerView {
		ForecastDetailsView(viewModel: ViewModelsFactory.getForecastDetailsViewModel(forecasts: [.init(tz: "Europe/Athens", date: "", hourly: [.mockInstance], daily: .mockInstance)],
																					 device: .mockDevice,
																					 followState: .init(deviceId: "", relation: .owned)))
	}
}

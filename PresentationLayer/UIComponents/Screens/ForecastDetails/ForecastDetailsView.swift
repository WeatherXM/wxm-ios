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
			}
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var dailyConditionsFields: some View {
		PercentageGridLayoutView(alignments: [.center, .center], firstColumnPercentage: 0.5) {
			Group {

			}
		}
	}
}

#Preview {
	NavigationContainerView {
		ForecastDetailsView(viewModel: ViewModelsFactory.getForecastDetailsViewModel(forecasts: [.init(tz: "Europe/Athens", date: "", hourly: [], daily: .mockInstance)],
																					 device: .mockDevice,
																					 followState: .init(deviceId: "", relation: .owned)))
	}
}

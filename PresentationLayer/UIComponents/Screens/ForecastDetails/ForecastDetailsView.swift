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
	@State private var isTransitioning: Bool = false

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
					}.padding(.horizontal, CGFloat(.mediumSidePadding))

					dailyForecast
						.padding(.horizontal, CGFloat(.mediumSidePadding))


					ZStack {
						if let item = viewModel.detailsDailyItem {
							ForecastDetailsDailyView(item: item)
								.id(item.forecast?.daily?.timestamp)
								.padding(.horizontal, CGFloat(.mediumSidePadding))
						}
					}
					.overlay {
						if isTransitioning {
							Color(colorEnum: .newBG)
						}
					}
					.onChange(of: viewModel.isTransitioning) { newValue in
						withAnimation {
							isTransitioning = newValue
						}
					}
				}
			}
		}.onAppear {
			navigationObject.navigationBarColor = Color(.newBG)
		}
	}
}

private extension ForecastDetailsView {

	@ViewBuilder
	var dailyForecast: some View {
		let dailyItems = viewModel.dailyItems
		if !dailyItems.isEmpty {
			ScrollViewReader { proxy in
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: CGFloat(.smallSpacing)) {
						ForEach(0..<dailyItems.count, id: \.self) { index in
							let item = dailyItems[index]
							StationForecastMiniCardView(item: item, isSelected: viewModel.selectedForecastIndex == index)
								.wxmShadow()
								.frame(width: 80.0)
								.id(index)
						}
					}
				}
				.onChange(of: viewModel.selectedForecastIndex) { index in
					withAnimation {
						proxy.scrollTo(index, anchor: .center)
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
		let forecasts: [NetworkDeviceForecastResponse] = (0..<6).map { _ in .init(tz: "Europe/Athens", date: "", hourly: (0..<24).map {_ in .mockInstance }, daily: .mockInstance) }
		ForecastDetailsView(viewModel: ViewModelsFactory.getForecastDetailsViewModel(configuration: .init(forecasts: forecasts,
																										  selectedforecastIndex: 0,
																										  selectedHour: nil,
																										  device: .mockDevice,
																										  followState: .init(deviceId: "", relation: .owned))))
	}
}

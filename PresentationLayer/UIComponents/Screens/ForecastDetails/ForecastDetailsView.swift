//
//  ForecastDetailsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import SwiftUI
import DomainLayer
import Toolkit

struct ForecastDetailsView: View {
	@StateObject var viewModel: ForecastDetailsViewModel
	@EnvironmentObject var navigationObject: NavigationObject
	@State private var isTransitioning: Bool = false

	var body: some View {
		ZStack {
			Color(colorEnum: .topBG)
				.ignoresSafeArea()

			ScrollViewReader { proxy in
				ScrollView(showsIndicators: false) {
					VStack(spacing: CGFloat(.largeSpacing)) {
						NavigationTitleView(title: .constant(viewModel.navigationTitle),
											subtitle: .constant(viewModel.navigationSubtitle)) {
							Group {
								if let faIcon = viewModel.fontIconState {
									Button {
										viewModel.handleTopButtonTap()
									} label: {
										Text(faIcon.icon.rawValue)
											.font(.fontAwesome(font: faIcon.font, size: CGFloat(.mediumFontSize)))
											.foregroundColor(Color(colorEnum: faIcon.color))
									}
									.disabled(!viewModel.isTopButtonEnabled)
								} else {
									EmptyView()
								}
							}
						}.padding(.horizontal, CGFloat(.mediumSidePadding))
						
						VStack(spacing: CGFloat(.largeSpacing)) {
							dailyForecast
								.padding(.horizontal, CGFloat(.mediumSidePadding))
							
							ZStack {
								if let item = viewModel.detailsDailyItem {
									ForecastDetailsDailyView(viewModel: viewModel,
															 item: item,
															 scrollProxy: proxy)
										.padding(.horizontal, CGFloat(.mediumSidePadding))
								}
							}
							.overlay {
								if isTransitioning {
									Color(colorEnum: .topBG)
								}
							}
							.onChange(of: viewModel.isTransitioning) { newValue in
								withAnimation {
									isTransitioning = newValue
								}
							}
						}
						.clipped()
						.iPadMaxWidth()
					}
				}
			}
		}.onAppear {
			navigationObject.navigationBarColor = Color(.topBG)

			WXMAnalytics.shared.trackScreen(.forecastDetails)
		}
		.wxmAlert(show: $viewModel.showLoginAlert) {
			WXMAlertView(show: $viewModel.showLoginAlert,
						 configuration: viewModel.alertConfiguration!) {
				Button {
					viewModel.signupButtonTapped()
				} label: {
					HStack {
						Text(LocalizableString.dontHaveAccount.localized)
							.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
							.foregroundColor(Color(colorEnum: .text))

						Text(LocalizableString.signUp.localized.uppercased())
							.font(.system(size: CGFloat(.normalFontSize)))
							.foregroundColor(Color(colorEnum: .wxmPrimary))
					}
				}
			}
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
					HStack(spacing: CGFloat(.smallSpacing)) {
						ForEach(0..<dailyItems.count, id: \.self) { index in
							let item = dailyItems[index]
							StationForecastMiniCardView(item: item, isSelected: viewModel.selectedForecastIndex == index)
								.wxmShadow()
								.frame(width: StationForecastMiniCardView.defaultWidth)
								.id(index)
						}
					}
				}
				.disableScrollClip()
				.onChange(of: viewModel.selectedForecastIndex) { index in
					withAnimation {
						proxy.scrollTo(index, anchor: .center)
					}
				}
				.onAppear {
					if let selectedIndex = viewModel.selectedForecastIndex {
						proxy.scrollTo(selectedIndex, anchor: .center)
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

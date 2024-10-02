//
//  RewardAnalyticsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import SwiftUI
import DomainLayer

struct RewardAnalyticsView: View {
	@StateObject var viewModel: RewardAnalyticsViewModel

    var body: some View {
		NavigationContainerView {
			ContentView(viewModel: viewModel)
		}
    }
}

extension RewardAnalyticsView {
	enum State {
		case empty(WXMEmptyView.Configuration)
		case noRewards
		case content		
	}
}

private struct ContentView: View {
	@EnvironmentObject var navigationObject: NavigationObject
	@ObservedObject var viewModel: RewardAnalyticsViewModel
	private let animationDuration = 0.3

	var body: some View {
		ZStack {
			Color(colorEnum: .topBG)
				.ignoresSafeArea()
			
			Group {
				switch viewModel.state {
					case .empty(let configuration):
						emptyView(configuration: configuration)
					case .noRewards:
						noRewards
					case .content:
						rewardsView
				}
			}
		}
		.onAppear {
			navigationObject.title = LocalizableString.RewardAnalytics.stationRewards.localized
		}
	}

	@ViewBuilder
	func emptyView(configuration: WXMEmptyView.Configuration) -> some View {
		WXMEmptyView(configuration: configuration, backgroundColor: .background)
	}

	@ViewBuilder
	var noRewards: some View {
		TrackableScrollView {
			VStack(spacing: CGFloat(.defaultSidePadding)) {
				titleView
				NoRewardsView(showTipView: false)
					.wxmShadow()
			}
			.padding(CGFloat(.defaultSidePadding))
		}
	}

	@ViewBuilder
	var rewardsView: some View {
		ScrollViewReader { proxy in
			TrackableScrollView {
				VStack(spacing: CGFloat(.defaultSidePadding)) {
					titleView

					summaryCard
						.wxmShadow()

					stationsList(scrollProxy: proxy)
				}
				.padding(CGFloat(.defaultSidePadding))
			}
			.animation(.easeIn(duration: animationDuration),
					   value: viewModel.stationItems.values.reduce(into: 0) { $0 = $0 + ($1.isExpanded ? 1 : 0) })
		}
	}

	@ViewBuilder
	var titleView: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(LocalizableString.RewardAnalytics.totalEarnedFor(viewModel.devices.count).localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .darkGrey))
				Spacer()

				Text(LocalizableString.RewardAnalytics.lastRun.localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .darkGrey))
			}

			HStack(alignment: .bottom) {
				Text(viewModel.totalEearnedText)
					.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .darkGrey))
				
				Spacer()

				Text(viewModel.lastRunValueText)
					.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .lastRun))
			}
		}
	}

	@ViewBuilder
	var summaryCard: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack {
				VStack(alignment: .leading, spacing: CGFloat(.smallSpacing)) {
					Text(LocalizableString.RewardAnalytics.totalEarned.localized)
						.font(.system(size: CGFloat(.largeFontSize), weight: .bold))

					Text(viewModel.summaryEarnedValueText)
						.font(.system(size: CGFloat(.normalFontSize)))

				}
				.foregroundStyle(Color(colorEnum: .text))

				Spacer()

				CustomSegmentView(options: DeviceRewardsMode.allCases.map { $0.description },
								  selectedIndex: Binding(get: { viewModel.summaryMode.index ?? 0 },
														 set: { index in
					viewModel.summaryMode = DeviceRewardsMode.value(for: index)
				}),
								  style: .compact)
				.cornerRadius(CGFloat(.buttonCornerRadius))
			}

			Group {
				if let dataItems = viewModel.summaryChartDataItems {
					ChartView(data: dataItems)
						.aspectRatio(3.0/2.0, contentMode: .fit)
				} else if viewModel.showSummaryError, let failObj = viewModel.summaryFailObject {
					FailView(obj: failObj)
				}
			}
			.spinningLoader(show: $viewModel.suammaryRewardsIsLoading,
							hideContent: true)
		}
		.id(viewModel.summaryMode)
		.WXMCardStyle()
		.animation(.easeIn(duration: animationDuration), value: viewModel.suammaryRewardsIsLoading)
		.if(viewModel.summaryChartDataItems == nil) { view in
			view
				.spinningLoader(show: $viewModel.suammaryRewardsIsLoading,
								lottieLoader: false)
		}
	}

	@ViewBuilder
	func stationsList(scrollProxy: ScrollViewProxy) -> some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			HStack {
				Text(LocalizableString.RewardAnalytics.rewardsByStation.localized)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			ForEach(viewModel.devices) { device in
				stationView(device: device, scrollProxy: scrollProxy)
					.wxmShadow()
					.id(device.id)
			}
		}
	}

	@ViewBuilder
	func stationView(device: DeviceDetails, scrollProxy: ScrollViewProxy) -> some View {
		let isExpanded = viewModel.isExpanded(device: device)
		VStack(spacing: CGFloat(.defaultSpacing)) {
			Button {
				viewModel.handleDeviceTap(device) {
					if !isExpanded {
						// Scroll to expanded once the expand animation is finished
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
							withAnimation {
								scrollProxy.scrollTo(device.id, anchor: .top)
							}
						}
					}
				}
			} label: {
				HStack {
					Text(device.displayName)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .medium))
						.foregroundStyle(Color(colorEnum: .text))
					Spacer()

					HStack(spacing: CGFloat(.mediumSpacing)) {
						let precisionString = device.rewards?.totalRewards?.toWXMTokenPrecisionString ?? "0.00"
						Text(precisionString + " " + StringConstants.wxmCurrency)
							.font(.system(size: CGFloat(.mediumFontSize), weight: .medium))
							.foregroundStyle(Color(colorEnum: .text))

						Text(FontIcon.chevronDown.rawValue)
							.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
							.foregroundStyle(Color(colorEnum: .darkGrey))
							.rotationEffect(Angle(degrees: isExpanded ? -180 : 0.0))
							.animation(.easeIn(duration: animationDuration), value: isExpanded)
					}
				}
			}

			if isExpanded, let stationItem = viewModel.stationItems[device.id ?? ""] {
				VStack(spacing: CGFloat(.smallToMediumSpacing)) {
					HStack {
						Text(LocalizableString.RewardAnalytics.rewardsBreakdown.localized)
							.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
							.foregroundStyle(Color(colorEnum: .text))
						Spacer()
					}

					rewardsBreakdownSegmentView(deviceId: device.id ?? "", stationItem: stationItem)
				}

				VStack(spacing: CGFloat(.defaultSpacing)) {
					if let deviceId = device.id,
					   let currentStationChartData = viewModel.stationItems[deviceId]?.chartDataItems,
					   let legendItems = viewModel.stationItems[deviceId]?.legendItems {
						VStack(spacing: CGFloat(.mediumSpacing)) {
							ChartView(mode: .area, data: currentStationChartData) { total in
								return total.toWXMTokenPrecisionString
							}
							.aspectRatio(3.0/2.0, contentMode: .fit)
							.frame(maxWidth: .infinity, maxHeight: .infinity)

							HStack {
								ChartLegendView(items: legendItems)
								Spacer()
							}
						}
					} else if let deviceId = device.id,
							  viewModel.stationItems[deviceId]?.stationError == true,
							  let obj = viewModel.stationItems[deviceId]?.failObject {
						FailView(obj: obj)
					}
					ForEach(viewModel.stationItems[device.id ?? ""]?.reward?.details ?? [], id: \.code) { details in
						StationRewardDetailsView(details: details)
					}
				}
				.id(viewModel.stationItems[device.id ?? ""]?.mode)
				.animation(.easeIn(duration: animationDuration), value: viewModel.stationItems[device.id ?? ""]?.isLoading)
				.spinningLoader(show: Binding(get: { viewModel.stationItems[device.id ?? ""]?.isLoading == true },
											  set: { _ in }),
								hideContent: true)
			}
		}
		.WXMCardStyle()
		.animation(.easeIn(duration: animationDuration), value: isExpanded)
		.if(!isExpanded) { view in
			view
				.spinningLoader(show: Binding(get: { viewModel.stationItems[device.id ?? ""]?.isLoading == true },
											  set: { _ in }),
								lottieLoader: false)
		}
	}
}

private extension ContentView {
	@ViewBuilder
	func rewardsBreakdownSegmentView(deviceId: String, stationItem: RewardAnalyticsViewModel.StationItem) -> some View {
		HStack(alignment: .top) {
			VStack(alignment: .leading, spacing: 0.0) {
				Text(LocalizableString.RewardAnalytics.earnedByThisStation.localized)
					.font(.system(size: CGFloat(.caption)))
					.foregroundStyle(Color(colorEnum: .text))

				if !stationItem.isLoading,
				   let rewards = stationItem.reward?.total {
					Text(rewards.toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency)
						.font(.system(size: CGFloat(.mediumFontSize)))
						.foregroundStyle(Color(colorEnum: .text))
				}
			}

			Spacer()

			CustomSegmentView(options: DeviceRewardsMode.allCases.map { $0.description },
							  selectedIndex: Binding(get: { stationItem.mode.index ?? 0 },
													 set: { index in
				viewModel.setMode(DeviceRewardsMode.value(for: index), for: deviceId)
			}),
							  style: .compact)
			.cornerRadius(CGFloat(.buttonCornerRadius))
		}
	}

}

#Preview {
	RewardAnalyticsView(viewModel: ViewModelsFactory.getRewardAnalyticsViewModel(devices: [DeviceDetails.mockDevice]))
}

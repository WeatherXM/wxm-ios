//
//  RewardAnalyticsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import SwiftUI
import DomainLayer
import Toolkit

struct RewardAnalyticsView: View {
	@StateObject var viewModel: RewardAnalyticsViewModel

    var body: some View {
		NavigationContainerView {
			ContentView(viewModel: viewModel)
		}
    }
}

extension RewardAnalyticsView {
	enum State: Equatable {
		case empty(WXMEmptyView.Configuration)
		case noRewards
		case content

		static func == (lhs: RewardAnalyticsView.State, rhs: RewardAnalyticsView.State) -> Bool {
			switch (lhs, rhs) {
				case (.empty(let lhsConfig), .empty(let rhsConfig)):
					return lhsConfig.title == rhsConfig.title
				case (.noRewards, .noRewards):
					return true
				case (.content, .content):
					return true
				default:
					return false
			}
		}
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
							.iPadMaxWidth()
					case .noRewards:
						noRewards
							.iPadMaxWidth()
					case .content:
						rewardsView
				}
			}
		}
		.onAppear {
			navigationObject.title = LocalizableString.RewardAnalytics.stationRewards.localized
			WXMAnalytics.shared.trackScreen(.rewardAnalytics)
		}
	}

	@ViewBuilder
	func emptyView(configuration: WXMEmptyView.Configuration) -> some View {
		WXMEmptyView(configuration: configuration)
	}

	@ViewBuilder
	var noRewards: some View {
		ScrollView {
			VStack(spacing: CGFloat(.defaultSidePadding)) {
				titleView
				NoRewardsView(showTipView: false)
					.wxmShadow()
			}
			.padding(CGFloat(.defaultSidePadding))
		}
		.scrollIndicators(.hidden)
	}

	@ViewBuilder
	var rewardsView: some View {
		ScrollViewReader { proxy in
			ScrollView {
				VStack(spacing: CGFloat(.defaultSidePadding)) {
					titleView

					summaryCard
						.wxmShadow()

					stationsList(scrollProxy: proxy)
				}
				.padding(CGFloat(.defaultSidePadding))
				.iPadMaxWidth()
			}
			.scrollIndicators(.hidden)
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
					.foregroundStyle(Color(colorEnum: .text))
				
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
				if viewModel.showSummaryError, let failObj = viewModel.summaryFailObject {
					FailView(obj: failObj)
						.padding()
				} else {
					ChartView(data: viewModel.summaryChartDataItems ?? [])
						.aspectRatio(3.0/2.0, contentMode: .fit)
				}
			}
			.spinningLoader(show: $viewModel.suammaryRewardsIsLoading,
							hideContent: true)
			.id(viewModel.summaryMode)
		}
		.WXMCardStyle()
		.animation(.easeIn(duration: animationDuration),
				   value: viewModel.suammaryRewardsIsLoading)
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
		let deviceId = device.id ?? ""
		let stationItem = viewModel.stationItems[deviceId]
		let isExpanded = stationItem?.isExpanded == true
		VStack(spacing: CGFloat(.defaultSpacing)) {
			Button {
				viewModel.handleDeviceTap(device)
				if !isExpanded {
					// Scroll to expanded once the expand animation is finished
					withAnimation {
						scrollProxy.scrollTo(device.id, anchor: .top)
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

			if isExpanded, let stationItem {
				expandedView(for: deviceId , stationItem: stationItem)
			}
		}
		.WXMCardStyle()
		.animation(.easeIn(duration: animationDuration), value: isExpanded)
	}

	@ViewBuilder
	func expandedView(for deviceId: String, stationItem: RewardAnalyticsViewModel.StationCardItem) -> some View {
		VStack(spacing: CGFloat(.smallToMediumSpacing)) {
			HStack {
				Text(LocalizableString.RewardAnalytics.rewardsBreakdown.localized)
					.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
					.foregroundStyle(Color(colorEnum: .text))
				Spacer()
			}

			rewardsBreakdownSegmentView(deviceId: deviceId, stationItem: stationItem)
		}

		VStack(spacing: CGFloat(.defaultSpacing)) {
			if let currentStationChartData = stationItem.chartDataItems,
			   let legendItems = stationItem.legendItems {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					ChartView(mode: .area, data: currentStationChartData) { total in
						return total.toWXMTokenPrecisionString
					}
					.aspectRatio(3.0/2.0, contentMode: .fit)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.transaction { transaction in
						transaction.animation = nil
					}

					HStack {
						ChartLegendView(items: legendItems)
						Spacer()
					}
				}
			} else if stationItem.stationError == true,
					  let obj = stationItem.failObject {
				FailView(obj: obj)
					.padding()
			}

			ForEach(stationItem.reward?.details ?? [], id: \.code) { details in
				StationRewardDetailsView(details: details)
			}
		}
		.frame(minHeight: SpinningLoaderView.dimensions)
		.id(stationItem.mode)
		.animation(.easeIn(duration: animationDuration),
				   value: stationItem.isLoading)
		.spinningLoader(show: Binding(get: { stationItem.isLoading == true },
									  set: { _ in }),
						hideContent: true)
	}
}

private extension ContentView {
	@ViewBuilder
	func rewardsBreakdownSegmentView(deviceId: String, stationItem: RewardAnalyticsViewModel.StationCardItem) -> some View {
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

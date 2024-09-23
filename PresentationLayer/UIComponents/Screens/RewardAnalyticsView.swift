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
		TrackableScrollView { completion in
			viewModel.refresh(completion: completion)
		} content: {
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
		TrackableScrollView { completion in
			viewModel.refresh(completion: completion)
		} content: {
			VStack(spacing: CGFloat(.defaultSidePadding)) {
				titleView

				summaryCard
					.wxmShadow()

				stationsList
			}
			.padding(CGFloat(.defaultSidePadding))
		}
		.animation(.easeIn(duration: animationDuration), value: viewModel.currentStationReward != nil)
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

			if let chartDataItems = viewModel.summaryChartDataItems {
				ChartView(data: chartDataItems)
					.aspectRatio(1.0, contentMode: .fit)
			}
		}
		.WXMCardStyle()
		.spinningLoader(show: $viewModel.suammaryRewardsIsLoading)
		.animation(.easeIn(duration: animationDuration), value: viewModel.suammaryRewardsIsLoading)
	}

	@ViewBuilder
	var stationsList: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			HStack {
				Text(LocalizableString.RewardAnalytics.rewardsByStation.localized)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			ForEach(viewModel.devices) { device in
				stationView(device: device)
					.wxmShadow()
			}
		}
	}

	@ViewBuilder
	func stationView(device: DeviceDetails) -> some View {
		let isExpanded = viewModel.isExpanded(device: device)
		VStack(spacing: CGFloat(.defaultSpacing)) {
			Button {
				viewModel.handleDeviceTap(device)
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

			if isExpanded {
				HStack {
					Text(LocalizableString.RewardAnalytics.rewardsBreakdown.localized)
						.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
						.foregroundStyle(Color(colorEnum: .text))
					Spacer()
				}

				rewardsBreakdownSegmentView

				Group {
					if let currentStationChartData = viewModel.currentStationChartDataItems {
						ChartView(mode: .area, data: currentStationChartData)
							.aspectRatio(1.0, contentMode: .fit)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
					}
					ForEach(viewModel.currentStationReward?.stationReward.details ?? [], id: \.code) { details in
						StationRewardDetailsView(details: details)
					}
				}
				.animation(.easeIn(duration: animationDuration), value: viewModel.currentStationIdLoading)
			}
		}
		.spinningLoader(show: Binding(get: { viewModel.currentStationIdLoading == device.id },
									  set: { _ in }),
						lottieLoader: isExpanded)
		.WXMCardStyle()
		.animation(.easeIn(duration: animationDuration), value: isExpanded)
	}
}

private extension ContentView {
	@ViewBuilder
	var rewardsBreakdownSegmentView: some View {
		HStack {
			VStack(alignment: .leading, spacing: 0.0) {
				Text(LocalizableString.RewardAnalytics.earnedByThisStation.localized)
					.font(.system(size: CGFloat(.caption)))
					.foregroundStyle(Color(colorEnum: .text))

				Text((viewModel.currentStationReward?.stationReward.total ?? 0.0).toWXMTokenPrecisionString + " " + StringConstants.wxmCurrency)
					.font(.system(size: CGFloat(.mediumFontSize)))
					.foregroundStyle(Color(colorEnum: .text))
			}

			Spacer()

			CustomSegmentView(options: DeviceRewardsMode.allCases.map { $0.description },
							  selectedIndex: Binding(get: { viewModel.currenStationMode.index ?? 0 },
													 set: { index in
				viewModel.currenStationMode = DeviceRewardsMode.value(for: index)
			}),
							  style: .compact)
			.cornerRadius(CGFloat(.buttonCornerRadius))
		}
	}

}

#Preview {
	RewardAnalyticsView(viewModel: ViewModelsFactory.getRewardAnalyticsViewModel(devices: [DeviceDetails.mockDevice]))
}

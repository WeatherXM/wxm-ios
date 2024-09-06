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

	@State private var selectedIndex: Int = 0

	var body: some View {
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
		TrackableScrollView {
			VStack(spacing: CGFloat(.defaultSidePadding)) {
				titleView

				summaryCard
					.wxmShadow()

				stationsList
			}
			.padding(CGFloat(.defaultSidePadding))
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
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .success))
			}
		}
	}

	@ViewBuilder
	var summaryCard: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack {
				VStack(spacing: CGFloat(.smallSpacing)) {
					Text(LocalizableString.RewardAnalytics.totalEarned.localized)
						.font(.system(size: CGFloat(.largeFontSize), weight: .bold))

					Text(viewModel.overallEarnedValueText)
						.font(.system(size: CGFloat(.normalFontSize)))

				}
				.foregroundStyle(Color(colorEnum: .text))

				Spacer()

				CustomSegmentView(options: ["7D", "1M", "1Y"],
								  selectedIndex: $selectedIndex,
								  style: .compact)
				.cornerRadius(CGFloat(.buttonCornerRadius))
			}

			if let chartDataItems = viewModel.overallChartDataItems {
				ChartView(data: chartDataItems)
					.aspectRatio(1.0, contentMode: .fit)
			}
		}
		.WXMCardStyle()
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
							.animation(.easeIn(duration: 0.3), value: isExpanded)
					}
				}
			}

			if isExpanded {
				ForEach(viewModel.currentStationReward?.stationReward.details ?? [], id: \.code) { details in
					StationRewardDetailsView(details: details)
				}
			}
		}
		.WXMCardStyle()
		.animation(.easeIn(duration: 0.3), value: isExpanded)
	}
}

#Preview {
	RewardAnalyticsView(viewModel: ViewModelsFactory.getRewardAnalyticsViewModel(devices: [DeviceDetails.mockDevice]))
}

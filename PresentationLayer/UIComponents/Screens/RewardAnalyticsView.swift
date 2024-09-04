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
		VStack {
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
		}
		.WXMCardStyle()
	}
}

#Preview {
	RewardAnalyticsView(viewModel: ViewModelsFactory.getRewardAnalyticsViewModel(devices: [DeviceDetails.mockDevice]))
}

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
}

#Preview {
	RewardAnalyticsView(viewModel: .init(devices: [DeviceDetails.mockDevice]))
}

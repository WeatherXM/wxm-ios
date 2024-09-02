//
//  RewardAnalyticsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import SwiftUI

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
					EmptyView()
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
		NoRewardsView()
	}

	@ViewBuilder
	var rewardsView: some View {
		EmptyView()
	}
}

#Preview {
	RewardAnalyticsView(viewModel: .init(devices: []))
}

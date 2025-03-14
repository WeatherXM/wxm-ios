//
//  RewardsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/3/23.
//

import SwiftUI
import Toolkit
struct StationRewardsView: View {
    @StateObject var viewModel: StationRewardsViewModel

    var body: some View {
		GeometryReader { proxy in
			ZStack {
				TrackableScroller(showIndicators: false,
								  offsetObject: viewModel.offsetObject) { completion in
					viewModel.refresh(completion: completion)
				} content: {
					VStack(spacing: CGFloat(.mediumSpacing)) {
						if viewModel.viewState == .empty {
							NoRewardsView()
								.wxmShadow()
						} else {
							TotalRewardsView(rewards: viewModel.response?.totalRewards ?? 0.0)
								.wxmShadow()

							if let data = viewModel.response?.latest {
								DailyRewardCardView(card: data.toDailyRewardCard(isOwned: viewModel.isDeviceOwned)) {
									viewModel.handleViewDetailsTap()
								}
								.wxmShadow()
							}

							WeeklyStreakView(entries: viewModel.response?.timeline?.toWeeklyEntries ?? []) {
								viewModel.handleDetailedRewardsButtonTap()
							}
							.wxmShadow()
						}
					}
					.iPadMaxWidth()
					.padding()
					.padding(.bottom, proxy.size.height / 2.0) // Quick fix for better experience while expanding/collapsing the containers's header
				}
				.spinningLoader(show: Binding(get: { viewModel.viewState == .loading }, set: { _ in }), hideContent: true)
				.fail(show: Binding(get: { viewModel.viewState == .fail }, set: { _ in }), obj: viewModel.failObj)
			}
		}
    }
}

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        StationRewardsView(viewModel: StationRewardsViewModel(deviceId: "", useCase: nil))
			.background(Color.red)
    }
}

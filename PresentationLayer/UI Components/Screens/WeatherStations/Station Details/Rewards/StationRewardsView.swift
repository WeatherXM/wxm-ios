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
				TrackableScrollView(offsetObject: viewModel.offsetObject) { completion in
					viewModel.refresh(completion: completion)
				} content: {
					VStack(spacing: CGFloat(.mediumSpacing)) {
						if viewModel.showMainnet == true, let message = viewModel.mainnetMessage {
							AnnouncementCardView(title: LocalizableString.StationDetails.mainnetTitle.localized,
												 description: message)
						}

						if viewModel.viewState == .empty {
							NoRewardsView()
						} else {
							TotalRewardsView(rewards: viewModel.response?.totalRewards ?? 0.0)
								.wxmShadow()

							if let data = viewModel.response?.latest {
								DailyRewardCardView(card: data.toDailyRewardCard) {
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
					#warning("TODO: Find a better solution")
				}
				.spinningLoader(show: Binding(get: { viewModel.viewState == .loading }, set: { _ in }), hideContent: true)
				.fail(show: Binding(get: { viewModel.viewState == .fail }, set: { _ in }), obj: viewModel.failObj)
			}
		}
        .onAppear {
            Logger.shared.trackScreen(.rewards)
        }
    }
}

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        StationRewardsView(viewModel: StationRewardsViewModel(deviceId: "", useCase: nil))
			.background(Color.red)
    }
}

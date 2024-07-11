//
//  RewardsTimelineView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 12/9/22.
//
import DomainLayer
import SwiftUI
import Toolkit

struct RewardsTimelineView: View {
    @StateObject var viewModel: RewardsTimelineViewModel
    @EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
        ZStack {
            Color(colorEnum: .bg)
                .ignoresSafeArea()
            
            timelineView
        }
        .onAppear {
            navigationObject.title = viewModel.device.displayName
            navigationObject.titleColor = Color(colorEnum: .wxmPrimary)

            WXMAnalytics.shared.trackScreen(.rewardTransactions)
        }
    }

    @ViewBuilder
	var timelineView: some View {
		ZStack(alignment: .bottom) {
			TrackableScrollView(showIndicators: false,
								offsetObject: viewModel.scrollOffsetObject) { completion in
				viewModel.refresh(showFullScreenLoader: false, reset: true, completion: completion)
			} content: {
				if viewModel.transactions.isEmpty {
					NoRewardsView()
						.padding(CGFloat(.mediumSidePadding))

				} else {
					timelineList
				}
			}
			.iPadMaxWidth()
			.spinningLoader(show: $viewModel.showFullScreenLoader, hideContent: true)
			.fail(show: $viewModel.isFailed, obj: viewModel.failObj)
		}
	}

	@ViewBuilder
	var timelineList: some View {
		ZStack(alignment: .topLeading) {
			timeLineOfTransactions
				.padding(.top, CGFloat(.minimumPadding))

			VStack(alignment: .leading, spacing: CGFloat(.mediumSpacing)) {
				ForEach(viewModel.transactions, id: \.self) { arrayOfTransactions in
					RewardDatePoint(dateOfTransaction: arrayOfTransactions.first!.timelineTransactionDateString)
					LazyVStack(spacing: CGFloat(.mediumSpacing)) {
						ForEach(arrayOfTransactions) { record in
							DailyRewardCardView(card: record.toDailyRewardCard(isOwned: false), buttonAction: nil)
								.wxmShadow()
								.onTapGesture {
									WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .transactionOnExplorer,
																					   .contentType: .deviceTransactions,
																					   .itemListId: .custom(record.timelineTransactionDateString),
																					   .itemId: .custom(viewModel.device.id ?? "")])

									viewModel.handleTransactionTap(from: record)
								}
								.onAppear {
									viewModel.fetchNextPageIfNeeded(for: record)
								}
						}
					}
					.padding(.horizontal, CGFloat(.mediumSidePadding))
				}

				if viewModel.isListFinished {
					RewardDatePoint(dateOfTransaction: "")

					endOfListView
						.padding(.horizontal, CGFloat(.mediumSidePadding))
				}

				if viewModel.isRequestInProgress {
					HStack {
						Spacer()
						ProgressView()
						Spacer()
					}
				}
			}
		}
		.padding(.top, CGFloat(.mediumSidePadding))
	}

    var timeLineOfTransactions: some View {
        Rectangle()
            .fill(Color(colorEnum: .midGrey))
            .frame(width: 4)
            .padding(.leading, 40)
    }

	@ViewBuilder
	var endOfListView: some View {
		VStack {
			HStack(spacing: CGFloat(.smallSpacing)) {
				Text(FontIcon.hexagonCheck.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
					.foregroundColor(Color(colorEnum: .darkGrey))

				Text(LocalizableString.StationDetails.timelineLimitMessage.localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .darkGrey))

				Spacer()
			}
		}
		.WXMCardStyle()
		.wxmShadow()
	}
}

#Preview {
	NavigationContainerView {
		RewardsTimelineView(viewModel: ViewModelsFactory.getTransactionDetailsViewModel(device: .mockDevice,
																						followState: nil))
	}
}

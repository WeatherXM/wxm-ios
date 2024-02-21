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
            navigationObject.titleColor = Color(colorEnum: .primary)

            Logger.shared.trackScreen(.rewardTransactions)
        }
    }

    @ViewBuilder
    var timelineView: some View {
        timelineList
			.iPadMaxWidth()
            .wxmEmptyView(show: Binding(get: { viewModel.transactions.isEmpty }, set: { _ in }),
                          configuration: .init(animationEnum: .emptyDevices,
                                               title: LocalizableString.noTransactionTitle.localized,
                                               description: LocalizableString.noTransactionDesc.localized.attributedMarkdown ?? "",
                                               buttonTitle: LocalizableString.retry.localized,
                                               action: { viewModel.refresh(showFullScreenLoader: true, reset: true) }))
            .spinningLoader(show: $viewModel.showFullScreenLoader, hideContent: true)
            .fail(show: $viewModel.isFailed, obj: viewModel.failObj)
    }

    @ViewBuilder
    var timelineList: some View {
        ZStack(alignment: .bottom) {
            TrackableScrollView(showIndicators: false,
                                offsetObject: viewModel.scrollOffsetObject) { completion in
                                    viewModel.refresh(showFullScreenLoader: false, reset: true, completion: completion)
			} content: {
                ZStack(alignment: .topLeading) {
                    timeLineOfTransactions
                    VStack(alignment: .leading) {
                        ForEach(viewModel.transactions, id: \.self) { arrayOfTransactions in
							RewardDatePoint(dateOfTransaction: arrayOfTransactions.first!.timelineTransactionDateString)
							LazyVStack(spacing: CGFloat(.mediumSpacing)) {
								ForEach(arrayOfTransactions) { record in
									DailyRewardCardView(card: record.toDailyRewardCard) {
										Logger.shared.trackEvent(.userAction, parameters: [.actionName: .transactionOnExplorer,
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
                            .padding(.top, CGFloat(.mediumSidePadding))
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
            }
        }
    }

    var timeLineOfTransactions: some View {
        Rectangle()
            .fill(Color(colorEnum: .midGrey))
            .frame(width: 4)
            .padding(.leading, 40)
            .padding(.top, 25)
    }
}

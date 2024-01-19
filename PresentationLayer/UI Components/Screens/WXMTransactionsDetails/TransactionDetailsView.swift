//
//  TransactionDetailsView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 12/9/22.
//
import DomainLayer
import SwiftUI
import Toolkit

struct TransactionDetailsView: View {
    @StateObject var viewModel: TransactionDetailsViewModel
    @EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
        ZStack {
            Color(colorEnum: .bg)
                .ignoresSafeArea()
            
            transactionDetails
        }
        .onAppear {
            navigationObject.title = viewModel.device.displayName
            navigationObject.titleColor = Color(colorEnum: .primary)

            Logger.shared.trackScreen(.rewardTransactions)
        }
    }

    @ViewBuilder
    var transactionDetails: some View {
        transactions
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
    var transactions: some View {
        ZStack(alignment: .bottom) {
            TrackableScrollView(showIndicators: false,
                                offsetObject: viewModel.scrollOffsetObject) { completion in
                                    viewModel.refresh(showFullScreenLoader: false, reset: true, completion: completion)
			} content: {
                ZStack(alignment: .topLeading) {
                    timeLineOfTransactions
                    VStack(alignment: .leading) {
                        ForEach(viewModel.transactions, id: \.self) { (arrayOfTransactions: [UITransaction]) in
                            RewardDatePoint(dateOfTransaction: arrayOfTransactions.first!.formattedDate)
                            LazyVStack(spacing: CGFloat(.mediumSpacing)) {
                                ForEach(arrayOfTransactions) { record in
									let lostData = record.lostAmountData
                                    BaseRewardsCard(record: record)
										.indication(show: .constant(!record.annotationsList.isEmpty),
													borderColor: Color(colorEnum: lostData.problemsViewBorder),
													bgColor: Color(colorEnum: lostData.problemsViewBackground)) {
											StationRewardsErrorView(lostAmount: record.lostAmount,
															 buttonTitle: viewModel.errorIndicationButtonTitle,
															 showButton: true) {
												viewModel.handleTransactionTap(from: record)
											}
											.padding(CGFloat(.defaultSidePadding))
										}
                                        .onTapGesture {
                                            Logger.shared.trackEvent(.userAction, parameters: [.actionName: .transactionOnExplorer,
                                                                                               .contentType: .deviceTransactions,
                                                                                               .itemListId: .custom(record.formattedTimestamp),
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

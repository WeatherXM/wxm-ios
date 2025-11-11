//
//  SubscriptionsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 7/11/25.
//

import SwiftUI
import StoreKit

struct SubscriptionsView: View {
	@StateObject var viewModel: SubscriptionsViewModel

    var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()
			VStack {
				ScrollView {
					VStack(spacing: CGFloat(.mediumSpacing)) {
						HStack {
							Text(LocalizableString.Subscriptions.selectPlan.localized)
								.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .text))

							Spacer()
						}

						ForEach(viewModel.cards) { card in
							Button {
								viewModel.selectedCard = card
							} label: {
								SubscriptionCardView(card: card, isSelected: viewModel.selectedCard == card)
							}
						}
					}
					.padding(CGFloat(.mediumSidePadding))
				}
				.scrollIndicators(.hidden)
				.refreshable {
					await viewModel.refresh()
				}

				Button {
					viewModel.continueButtonTapped()
				} label: {
					Text(LocalizableString.continue.localized)
				}
				.buttonStyle(WXMButtonStyle.filled())
				.padding(CGFloat(.mediumSidePadding))
				.disabled(!viewModel.canContinue)
			}
			.spinningLoader(show: $viewModel.isLoading)
		}
		.task {
			await viewModel.refresh()
		}
    }
}

#Preview {
	SubscriptionsView(viewModel: ViewModelsFactory.getSubscriptionsViewModel())
}

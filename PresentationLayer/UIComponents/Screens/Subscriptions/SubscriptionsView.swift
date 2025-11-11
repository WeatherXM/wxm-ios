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

			ScrollView {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					HStack {
						Text(LocalizableString.Subscriptions.selectPlan.localized)
							.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
							.foregroundStyle(Color(colorEnum: .text))

						Spacer()
					}
					
				}
				.padding(CGFloat(.mediumSidePadding))
			}
			.scrollIndicators(.hidden)
			.refreshable {
				await viewModel.refresh()
			}
			.spinningLoader(show: $viewModel.isLoading)
		}
    }
}

#Preview {
	SubscriptionsView(viewModel: ViewModelsFactory.getSubscriptionsViewModel())
}

//
//  TokenMetricsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/5/25.
//

import SwiftUI
import Toolkit

struct TokenMetricsView: View {
	@ObservedObject var viewModel: NetworkStatsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			ScrollView {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					totalAllocated
					tokenView
					lastUpdatedView
				}
				.padding(CGFloat(.defaultSidePadding))
			}
		}
		.onAppear {
			navigationObject.title = LocalizableString.NetStats.tokenMetrics.localized
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
			WXMAnalytics.shared.trackScreen(.tokenMetrics)
		}
    }
}

private extension TokenMetricsView {
	@ViewBuilder
	var lastUpdatedView: some View {
		if let lastUpdated = viewModel.lastUpdatedText {
			HStack {
				Spacer()

				Text(lastUpdated)
					.font(.system(size: CGFloat(.normalFontSize), weight: .thin))
					.foregroundColor(Color(colorEnum: .text))

			}
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var tokenView: some View {
		if let token = viewModel.token {
			generateStatsView(stats: token)
		} else {
			EmptyView()
		}
	}

	@ViewBuilder
	var totalAllocated: some View {
		if let totalAllocated = viewModel.totalAllocated {
			generateStatsView(stats: totalAllocated)
		} else {
			EmptyView()
		}
	}
}

#Preview {
	NavigationContainerView {
		TokenMetricsView(viewModel: ViewModelsFactory.getNetworkStatsViewModel())
	}
}

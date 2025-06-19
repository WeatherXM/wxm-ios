//
//  NetworkGrowthView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/6/25.
//

import SwiftUI

struct NetworkGrowthView: View {
	@ObservedObject var viewModel: NetworkStatsViewModel
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			ScrollView {
				VStack(spacing: CGFloat(.mediumSpacing)) {
					weatherStationsView
					lastUpdatedView
				}
				.padding(CGFloat(.defaultSidePadding))
			}
		}
		.onAppear {
			navigationObject.title = LocalizableString.NetStats.networkGrowth.localized
			navigationObject.navigationBarColor = Color(colorEnum: .bg)
		}
    }
}

extension NetworkGrowthView {
	@ViewBuilder
	var weatherStationsView: some View {
		if let stationStats = viewModel.stationStats {
			VStack(spacing: CGFloat(.mediumSpacing)) {
				HStack {
					Text(LocalizableString.NetStats.weatherStations.localized)
						.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .text))
					Spacer()
				}
				.padding(.horizontal, 24.0)

				VStack(spacing: CGFloat(.mediumSpacing)) {
					ForEach(stationStats, id: \.title) { stats in
						stationStatsView(statistics: stats) { statistics, details in
							viewModel.handleDetailsActionTap(statistics: statistics, details: details)
						}
					}
				}
				.padding(.horizontal, CGFloat(.smallToMediumSidePadding))
			}
			.WXMCardStyle(backgroundColor: Color(colorEnum: .top),
						  insideHorizontalPadding: 0.0,
						  insideVerticalPadding: CGFloat(.smallToMediumSidePadding))
			.wxmShadow()

		} else {
			EmptyView()
		}
	}

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
}

#Preview {
	NavigationContainerView {
		NetworkGrowthView(viewModel: ViewModelsFactory.getNetworkStatsViewModel())
	}
}

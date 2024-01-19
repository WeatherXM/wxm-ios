//
//  StationRewardsCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 25/10/23.
//

import SwiftUI
import Toolkit

struct StationRewardsCardView: View {
	@Binding var selectedIndex: Int
	let totalRewards: Double
	let showErrorButtonAction: Bool
	let overviews: [StationRewardsCardOverview]
	let buttonActions: RewardsOverviewButtonActions

    var body: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			titleView
				.padding(.top, CGFloat(.defaultSidePadding))
				.padding(.horizontal, CGFloat(.defaultSidePadding))

			contentView
		}
		.WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
					  insideHorizontalPadding: 0.0,
					  insideVerticalPadding: 0.0)
    }
}

private extension StationRewardsCardView {
	@ViewBuilder
	var titleView: some View {
		VStack(spacing: 0.0) {
			HStack {
				Text(LocalizableString.StationDetails.rewardsTitle.localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .text))
				Spacer()
			}

			HStack {
				Text("\(totalRewards, specifier: "%.2f") \(StringConstants.wxmCurrency)")
					.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .darkestBlue))
				Spacer()
			}
		}
	}

	@ViewBuilder
	var contentView: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			CustomSegmentView(options: overviews.map { $0.title }, selectedIndex: $selectedIndex)
			StationRewardsOverviewView(overview: overviews[selectedIndex], showErrorAction: showErrorButtonAction, buttonActions: buttonActions)
		}
		.WXMCardStyle()
	}
}

#Preview {
	ZStack {
		Color(colorEnum: .bg)
		StationRewardsCardView(selectedIndex: .constant(0),
							   totalRewards: 173023.54,
							   showErrorButtonAction: true,
							   overviews: [.mock(title: "Latest"), .mock(title: "7D"), .mock(title: "30D")],
							   buttonActions: .init(rewardsScoreInfoAction: {},
													dailyMaxInfoAction: {},
													timelineInfoAction: {},
													errorButtonAction: {}))
		.wxmShadow()
		.padding()
	}
}

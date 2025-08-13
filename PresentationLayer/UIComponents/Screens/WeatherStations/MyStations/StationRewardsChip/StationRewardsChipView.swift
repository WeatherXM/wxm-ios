//
//  StationRewardsChipView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/8/25.
//

import SwiftUI

struct StationRewardsChipView: View {
	@StateObject var viewModel: StationRewardsChipViewModel

    var body: some View {
		if let stationRewardsTitle = viewModel.stationRewardsTitle {
			Button {
				viewModel.handleRewardAnalyticsTap()
			} label: {
				HStack(spacing: CGFloat(.mediumSpacing)) {
					VStack(alignment: .leading, spacing: 0.0) {
						Text(stationRewardsTitle)
							.font(.system(size: CGFloat(.caption)))
							.foregroundStyle(Color(colorEnum: .text))

						if let stationRewardsValueText = viewModel.stationRewardsValueText {
							Text(stationRewardsValueText)
								.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
								.foregroundStyle(Color(colorEnum: .text))
						}
					}

					Text(FontIcon.chevronRight.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
						.foregroundColor(Color(colorEnum: .midGrey))

				}
				.WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
							  insideHorizontalPadding: CGFloat(.smallSidePadding),
							  insideVerticalPadding: CGFloat(.smallSidePadding),
							  cornerRadius: CGFloat(.buttonCornerRadius))
			}
			.transition(.opacity.animation(.easeIn))
		}
    }
}

#Preview {
	StationRewardsChipView(viewModel: ViewModelsFactory.getStationRewardsChipViewModel())
}

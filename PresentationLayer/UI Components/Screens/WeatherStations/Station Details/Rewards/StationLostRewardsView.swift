//
//  StationLostRewardsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 8/11/23.
//

import SwiftUI

struct StationLostRewardsView: View {

	let lostRewards: StationRewardsLostAmountData
	var rounded: Bool = true

	var body: some View {
		HStack(spacing: CGFloat(.smallSpacing)) {
			Text(lostRewards.fontIcon.rawValue)
				.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
				.foregroundColor(Color(colorEnum: lostRewards.iconColor))

			Text(title)
				.font(.system(size: CGFloat(.smallFontSize), weight: .bold))
				.foregroundColor(Color(colorEnum: .text))
		}
		.modify { view in
			if rounded {
				view
					.padding(CGFloat(.smallSidePadding))
					.background(Capsule().foregroundColor(Color(colorEnum: lostRewards.tintColor)))
			} else {
				view
					.WXMCardStyle(backgroundColor: Color(colorEnum: lostRewards.tintColor),
								  insideHorizontalPadding: CGFloat(.smallSidePadding),
								  insideVerticalPadding: CGFloat(.smallSidePadding),
								  cornerRadius: CGFloat(.buttonCornerRadius))
			}
		}
	}
}

private extension StationLostRewardsView {
	var title: String {
		let lostWxm = lostRewards.percentage > 0
		let title = lostWxm ? LocalizableString.StationDetails.lostRewards(lostRewards.percentage) : LocalizableString.StationDetails.gotRewards(100)

		return title.localized
	}
}

#Preview {
	StationLostRewardsView(lostRewards: StationRewardsLostAmountData(value: 190, percentage: 0))
}

#Preview {
	StationLostRewardsView(lostRewards: StationRewardsLostAmountData(value: 190, percentage: 50), rounded: false)
}

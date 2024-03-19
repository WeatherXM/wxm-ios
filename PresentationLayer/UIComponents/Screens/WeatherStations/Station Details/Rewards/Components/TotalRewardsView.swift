//
//  TotalRewardsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/2/24.
//

import SwiftUI

struct TotalRewardsView: View {
	let rewards: Double

    var body: some View {
		HStack(spacing: CGFloat(.defaultSpacing)) {
			Image(asset: .wxmBlackLogo)

			VStack(spacing: 0.0) {
				HStack {
					Text(LocalizableString.StationDetails.rewardsTitle.localized)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundColor(Color(colorEnum: .darkGrey))
					Spacer()
				}

				HStack {
					Text("\(rewards, specifier: "%.2f") \(StringConstants.wxmCurrency)")
						.font(.system(size: CGFloat(.titleFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .text))
					Spacer()
				}
			}
		}
		.WXMCardStyle()
    }
}

#Preview {
    TotalRewardsView(rewards: 14501234)
		.wxmShadow()
}

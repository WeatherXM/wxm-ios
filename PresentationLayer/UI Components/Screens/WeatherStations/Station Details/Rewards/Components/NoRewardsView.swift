//
//  NoRewardsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/2/24.
//

import SwiftUI

struct NoRewardsView: View {
	private let iconDimensions: CGFloat = 150

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			LottieView(animationCase: AnimationsEnums.rocket.animationString, loopMode: .loop)
				.frame(width: iconDimensions, height: iconDimensions)

			VStack(spacing: CGFloat(.smallSpacing)) {
				Text(LocalizableString.StationDetails.noRewardsTitle.localized)
					.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .text))
				Text(LocalizableString.StationDetails.noRewardsDescription.localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .text))
					.multilineTextAlignment(.center)
			}
		}
		.WXMCardStyle()
    }
}

#Preview {
	ZStack {
		Color.gray
		NoRewardsView()
			.wxmShadow()
			.padding()
	}
}

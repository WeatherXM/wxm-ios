//
//  NoRewardsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/2/24.
//

import SwiftUI

struct NoRewardsView: View {
	@Environment(\.colorScheme) var colorScheme
	private let iconDimensions: CGFloat = 150
	var animation: AnimationsEnums {
		switch colorScheme {
			case .dark:
				return .rocketDark
			case .light:
				return .rocket
			@unknown default:
				return .rocket
		}
	}

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			LottieView(animationCase: animation.animationString,
					   loopMode: .loop)
				.frame(width: iconDimensions, height: iconDimensions)
				.id(animation.animationString)

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
		.onChange(of: colorScheme) { value in
			print(value)
		}
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

//
//  NoRewardsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/2/24.
//

import SwiftUI

struct NoRewardsView: View {
	@Environment(\.colorScheme) var colorScheme
	
	var showTipView = true

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
		VStack(spacing: CGFloat(.mediumSpacing)) {
			VStack(spacing: CGFloat(.smallSpacing)) {
				LottieView(animationCase: animation.animationString,
						   loopMode: .loop)
				.frame(width: iconDimensions, height: iconDimensions)

				VStack(spacing: CGFloat(.smallSpacing)) {
					Text(LocalizableString.StationDetails.noRewardsTitle.localized)
						.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
						.foregroundColor(Color(colorEnum: .text))
					
					Text(LocalizableString.StationDetails.noRewardsDescription.localized)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundColor(Color(colorEnum: .text))
						.multilineTextAlignment(.center)
						.fixedSize(horizontal: false, vertical: true)
				}
			}

			if showTipView {
				tipView
			}
		}
		.WXMCardStyle()
		.onChange(of: colorScheme) { value in
			print(value)
		}
    }
}

private extension NoRewardsView {
	@ViewBuilder
	var tipView: some View {
		VStack(spacing: CGFloat(.minimumSpacing)) {
			HStack {
				Text(LocalizableString.StationDetails.proTipTitle.localized)
					.foregroundColor(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.caption), weight: .semibold))

				Spacer()
			}

			HStack {
				Text(LocalizableString.StationDetails.proTipDescription.localized)
					.foregroundColor(Color(colorEnum: .text))
					.font(.system(size: CGFloat(.caption)))
					.fixedSize(horizontal: false, vertical: true)

				Spacer()
			}
		}
		.padding(CGFloat(.smallSidePadding))
		.background {
			HStack(spacing: 0.0) {
				Color(colorEnum: .wxmPrimary)
					.frame(width: 1.0)
				Color(colorEnum: .blueTint)
			}
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

//
//  ForecastPoweredByView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/11/25.
//

import SwiftUI

struct ForecastPoweredByView: View {
	let isPremium: Bool

    var body: some View {
		HStack(spacing: CGFloat(.smallSpacing)) {
			Spacer()

			if isPremium {
				Text(FontIcon.bolt.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
					.foregroundStyle(Color(colorEnum: .accent))
			}

			Text(LocalizableString.Subscriptions.poweredBy.localized)
				.font(.system(size: CGFloat(.caption)))
				.foregroundStyle(Color(colorEnum: .text))

            Image(asset: isPremium ? .weatherXMLogoText : .meteoblueLogo)
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(Color(colorEnum: .text))
                .aspectRatio(contentMode: .fit)
                .frame(width: 50.0, height: 18.0)

			Spacer()
		}
		.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint),
					  insideVerticalPadding: CGFloat(.smallSidePadding),
					  cornerRadius: CGFloat(.smallCornerRadius))
    }
}

#Preview {
    ForecastPoweredByView(isPremium: false)
		.padding()
}

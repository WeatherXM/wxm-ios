//
//  ForecastPoweredByView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 24/11/25.
//

import SwiftUI

struct ForecastPoweredByView: View {
	let isPremium: Bool
    private var imageSize: CGSize {
        isPremium ? CGSize(width: 140.0, height: 20.0) : CGSize(width: 70.0, height: 20.0)
    }

    var body: some View {
        VStack(spacing: CGFloat(.smallSpacing)) {
            HStack(spacing: CGFloat(.smallSpacing)) {
                Spacer()

                Text(LocalizableString.Subscriptions.poweredBy.localized.capitalizedSentence)
                    .font(.system(size: CGFloat(.caption)))
                    .foregroundStyle(Color(colorEnum: .text))

                Spacer()
            }

            Image(asset: isPremium ? .weatherXMLogoText : .meteoblueLogo)
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(Color(colorEnum: .text))
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize.width, height: imageSize.height)
        }
		.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint),
					  insideVerticalPadding: CGFloat(.smallSidePadding),
					  cornerRadius: CGFloat(.smallCornerRadius))
    }
}

#Preview {
    ForecastPoweredByView(isPremium: true)
		.padding()
}

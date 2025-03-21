//
//  ProBannerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 21/3/25.
//

import SwiftUI

struct ProBannerView: View {
	let description: String

    var body: some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			Text(FontIcon.gem.rawValue)
				.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
				.foregroundStyle(Color(colorEnum: .text))

			VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
				Text(LocalizableString.Promotional.wxmPro.localized)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .wxmPrimary))

				Text(description)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .text))
					.multilineTextAlignment(.leading)
			}

			Spacer()
			Button {
				Router.shared.showBottomSheet(.proPromo(ViewModelsFactory.getProPromotionalViewModel()))
			} label: {
				Text(LocalizableString.Promotional.getPro.localized)
					.padding(.horizontal, CGFloat(.defaultSidePadding))
					.padding(.vertical, CGFloat(.smallToMediumSidePadding))
			}
			.buttonStyle(WXMButtonStyle.filled(fixedSize: true))

		}
		.WXMCardStyle(backgroundColor: Color(colorEnum: .blueTint))
    }
}

#Preview {
	ProBannerView(description: LocalizableString.Promotional.wantMoreAccurateForecast.localized)
}

//
//  MosaicCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/11/25.
//

import SwiftUI
import Toolkit

struct MosaicCardView: View {
	let plansAction: VoidCallback
	let freeSubscriptionAction: VoidCallback?

    var body: some View {
		VStack(spacing: CGFloat(.largeSpacing)) {
			VStack(spacing: CGFloat(.smallSpacing)) {
				Text(LocalizableString.Forecast.mosaic.localized)
					.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .wxmPrimary))

				Text(LocalizableString.Forecast.smarterSharper.localized)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

			}

			Text(LocalizableString.Forecast.mosaicCardDescription.localized)
				.font(.system(size: CGFloat(.normalFontSize)))
				.foregroundStyle(Color(colorEnum: .chartsTertiary))
				.multilineTextAlignment(.center)

			VStack(spacing: CGFloat(.smallSpacing)) {
				Button {
					plansAction()
				} label: {
					HStack {
						Spacer()

						Text(LocalizableString.Forecast.seeThePlans.localized)
							.font(.system(size: CGFloat(.largeFontSize)))
							.foregroundStyle(Color(colorEnum: .bg))
							.multilineTextAlignment(.center)

						Spacer()
					}
					.padding(.vertical, CGFloat(.mediumSidePadding))
				}
				.background {
					Capsule()
						.fill(Color(.wxmPrimary))
				}

				if let freeSubscriptionAction {
					Button {
						freeSubscriptionAction()
					} label: {
						Text(LocalizableString.Forecast.freeSubscriptionText.localized)
							.font(.system(size: CGFloat(.caption)))
							.foregroundStyle(Color(colorEnum: .chartsTertiary))
							.multilineTextAlignment(.center)
					}
				}
			}
		}
		.WXMCardStyle()
    }
}

#Preview {
    MosaicCardView(plansAction: { }, freeSubscriptionAction: nil)
}

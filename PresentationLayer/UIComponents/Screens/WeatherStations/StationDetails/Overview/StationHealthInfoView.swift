//
//  StationHealthInfoView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/10/24.
//

import SwiftUI
import Toolkit

struct StationHealthInfoView: View {
	let buttonAction: VoidCallback

	var body: some View {
		ZStack {
			Color(colorEnum: .bottomSheetBg)
				.ignoresSafeArea()

			VStack {
				VStack(spacing: CGFloat(.defaultSpacing)) {
					HStack {
						Text(LocalizableString.StationDetails.stationHealth.localized)
							.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
							.foregroundStyle(Color(colorEnum: .text))
						
						Spacer()
					}
					
					paragraph(title: LocalizableString.RewardDetails.dataQuality.localized,
							  text: LocalizableString.StationDetails.dataQualityDescription.localized)
					
					paragraph(title: LocalizableString.RewardDetails.locationQuality.localized,
							  text: LocalizableString.StationDetails.locationQualityDescription.localized)
					
				}
				.padding(CGFloat(.defaultSidePadding))
				.padding(.top)

				Button(action: buttonAction) {
					Text(LocalizableString.RewardDetails.readMore.localized)
				}
				.buttonStyle(WXMButtonStyle.transparent(fillColor: .bottomSheetButton))
				.padding(CGFloat(.defaultSidePadding))

			}
		}
    }
}

private extension StationHealthInfoView {
	@ViewBuilder
	func paragraph(title: String, text: String) -> some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(title)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			HStack {
				Text(text.attributedMarkdown ?? "")
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .text))
					.fixedSize(horizontal: false, vertical: true)

				Spacer(minLength: 0.0)
			}
		}
	}
}

#Preview {
	StationHealthInfoView() {
		
	}
}

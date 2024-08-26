//
//  AnnouncementCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/2/24.
//

import SwiftUI
import Toolkit

struct AnnouncementCardView: View {
	let title: String
	let description: String
	var actionTitle: String?
	var action: VoidCallback?

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack(spacing: CGFloat(.smallSpacing)) {
				Text(title)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .wxmWhite))
					.lineLimit(1)

				Spacer()
			}
			.foregroundColor(Color(colorEnum: .text))
			.minimumScaleFactor(0.8)

			Text(description)
				.font(.system(size: CGFloat(.normalFontSize)))
				.foregroundColor(Color(colorEnum: .wxmWhite))

			if let actionTitle, let action {
				HStack {
					Button(action: action) {
						HStack(spacing: CGFloat(.minimumSpacing)) {
							Text(actionTitle)
								.font(.system(size: CGFloat(.caption), weight: .bold))
								.foregroundColor(Color(colorEnum: .wxmWhite))

							Text(FontIcon.externalLink.rawValue)
								.font(.fontAwesome(font: .FAProSolid,
												   size: CGFloat(.caption)))
								.foregroundColor(Color(colorEnum: .wxmWhite))

						}
						.padding(.horizontal, CGFloat(.mediumSidePadding))
						.padding(.vertical, CGFloat(.smallSidePadding))
						.background {
							Capsule().foregroundStyle(Color(colorEnum: .wxmWhite).opacity(0.2))
						}
					}

					Spacer()
				}
			}
		}
		.padding(CGFloat(.defaultSidePadding))
		.background {
			Image(.announcementBackground)
				.resizable()
				.scaledToFill()
		}
		.WXMCardStyle(insideHorizontalPadding: 0.0, insideVerticalPadding: 0.0)
    }
}

#Preview {
    AnnouncementCardView(title: "Welcome to Mainnet!",
						 description: "Starting the Χth of Υ all station rewards are distributed on Abritrum Mainnet!\n\nThank you for the support!",
						 actionTitle: "Action title") { }
	.padding(.horizontal, 30)
}

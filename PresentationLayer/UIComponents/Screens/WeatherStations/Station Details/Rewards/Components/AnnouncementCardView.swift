//
//  AnnouncementCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/2/24.
//

import SwiftUI

struct AnnouncementCardView: View {
	let title: String
	let description: String
	
    var body: some View {
		VStack(spacing: CGFloat(.minimumSpacing)) {
			HStack(spacing: CGFloat(.smallSpacing)) {
				Spacer()

				Text(FontIcon.badgeCheck.rawValue)
					.font(.fontAwesome(font: .FAPro, size: CGFloat(.XLTitleFontSize)))
					.foregroundColor(Color(colorEnum: .white))


				Text(title)
					.font(.system(size: CGFloat(.XLTitleFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .white))
					.lineLimit(1)

				Spacer()
			}
			.foregroundColor(Color(colorEnum: .text))
			.minimumScaleFactor(0.8)

			Text(description)
				.font(.system(size: CGFloat(.mediumFontSize)))
				.foregroundColor(Color(colorEnum: .white))
				.multilineTextAlignment(.center)
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
						 description: "Starting the Χth of Υ all station rewards are distributed on Abritrum Mainnet!\n\nThank you for the support!")
	.padding(.horizontal, 30)
}

//
//  AnnouncementCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/2/24.
//

import SwiftUI
import Toolkit

struct AnnouncementCardView: View {
	let configuration: Configuration

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack(alignment: .top, spacing: CGFloat(.smallSpacing)) {
				Text(configuration.title)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .wxmWhite))

				Spacer()

				if let closeAction = configuration.closeAction {
					Button(action: closeAction) {
						Text(FontIcon.close.rawValue)
							.font(.fontAwesome(font: .FAProSolid,
											   size: CGFloat(.caption)))
							.foregroundColor(Color(colorEnum: .wxmWhite))
					}
				}
			}
			.foregroundColor(Color(colorEnum: .text))
			.minimumScaleFactor(0.8)

			HStack {
				Text(configuration.description)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundColor(Color(colorEnum: .wxmWhite))

				Spacer()
			}

			if let actionTitle = configuration.actionTitle,
			   let action = configuration.action {
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

extension AnnouncementCardView {
	struct Configuration {
		let title: String
		let description: String
		var actionTitle: String?
		var action: VoidCallback?
		var closeAction: VoidCallback?
	}
}

#Preview {
	AnnouncementCardView(configuration: .init(title: "Welcome to Mainnet!",
											  description: "Starting the Χth of Υ all station rewards are distributed on Abritrum Mainnet!\n\nThank you for the support!",
											  actionTitle: "Action title",
											  action: {},
											  closeAction: {}))
	.padding(.horizontal, 30)
}

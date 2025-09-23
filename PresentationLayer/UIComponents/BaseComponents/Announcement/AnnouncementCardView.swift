//
//  AnnouncementCardView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 19/2/24.
//

import SwiftUI
import Toolkit
import MarkdownUI

struct AnnouncementCardView: View {
	let configuration: Configuration

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack(alignment: .top, spacing: CGFloat(.smallSpacing)) {
				Text(configuration.title)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundColor(Color(colorEnum: .textWhite))

				Spacer()

				if let closeAction = configuration.closeAction {
					Button(action: closeAction) {
						Text(FontIcon.close.rawValue)
							.font(.fontAwesome(font: .FAProSolid,
											   size: CGFloat(.caption)))
							.foregroundColor(Color(colorEnum: .textWhite))
					}
				}
			}
			.foregroundColor(Color(colorEnum: .text))
			.minimumScaleFactor(0.8)

			HStack {
				Markdown(configuration.description)
					.markdownTextStyle {
						ForegroundColor(Color(colorEnum: .textWhite))
						FontFamily(.system(.default))
						FontSize(CGFloat(.normalFontSize))
					}
				Spacer()
			}

			if let actionTitle = configuration.actionTitle,
			   let action = configuration.action {
				HStack {
					Button(action: action) {
						HStack(spacing: CGFloat(.minimumSpacing)) {
							Text(actionTitle)
								.font(.system(size: CGFloat(.caption), weight: .bold))
								.foregroundColor(Color(colorEnum: .textWhite))
						}
						.padding(.horizontal, CGFloat(.mediumSidePadding))
						.padding(.vertical, CGFloat(.smallSidePadding))
						.background {
							Capsule().foregroundStyle(Color(colorEnum: .textWhite).opacity(0.2))
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
	struct Configuration: Equatable {
		static func == (lhs: AnnouncementCardView.Configuration, rhs: AnnouncementCardView.Configuration) -> Bool {
			lhs.title == rhs.title &&
			lhs.description == rhs.description &&
			lhs.actionTitle == rhs.actionTitle
		}

		let title: String
		let description: String
		var actionTitle: String?
		var action: VoidCallback?
		var closeAction: VoidCallback?
	}
}

#Preview {
	AnnouncementCardView(configuration: .init(title: "Welcome to Mainnet!",
											  description: "OK. Here's an analysis of your WeatherXM station, **Atomic Pine Yard**:\n\nThe station is **active** and located in Covas e Vila de Oliveira, PT.",
											  actionTitle: "Action title",
											  action: {},
											  closeAction: {}))
	.padding(.horizontal, 30)
}

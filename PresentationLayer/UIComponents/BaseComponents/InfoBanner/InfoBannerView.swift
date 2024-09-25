//
//  InfoBannerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 25/9/24.
//

import SwiftUI
import DomainLayer
import Toolkit

struct InfoBannerView: View {
	let infoBanner: InfoBanner
	let dismissAction: VoidCallback
	let tapUrlAction: GenericCallback<String>

	var body: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			VStack(spacing: CGFloat(.smallSpacing)) {
				HStack {
					Text(infoBanner.title ?? "")
						.font(.system(size: CGFloat(.largeFontSize), weight: .bold))
						.foregroundStyle(Color(colorEnum: .text))

					Spacer()

					if infoBanner.dismissable == true {
						Button {
							dismissAction()
						} label: {
							Text(FontIcon.close.rawValue)
								.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.largeFontSize)))
								.foregroundStyle(Color(colorEnum: .text))
						}

					}
				}

				HStack {
					Text(infoBanner.message ?? "")
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundStyle(Color(colorEnum: .text))

					Spacer()
				}
			}

			if infoBanner.buttonShow == true,
			   let actionLabel = infoBanner.actionLabel,
			   let url = infoBanner.url {
				HStack {
					Button {
						tapUrlAction(url)
					} label: {
						HStack(spacing: CGFloat(.minimumSpacing)) {
							Text(actionLabel)
								.font(.system(size: CGFloat(.caption), weight: .bold))
								.foregroundStyle(Color(colorEnum: .text))

							Text(FontIcon.externalLink.rawValue)
								.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.caption)))
								.foregroundStyle(Color(colorEnum: .text))
						}
						.padding(.horizontal, CGFloat(.mediumSidePadding))
						.padding(.vertical, CGFloat(.smallSidePadding))
					}
					.buttonStyle(WXMButtonStyle(fillColor: .top,
												strokeColor: .noColor,
												cornerRadius: CGFloat(.cardCornerRadius),
												fixedSize: true))

					Spacer()
				}
			}
		}
    }
}

#Preview {
	InfoBannerView(infoBanner: .init(id: "",
									 title: "Title",
									 message: "Message",
									 buttonShow: true,
									 actionLabel: "Action",
									 url: "url",
									 dismissable: true),
				   dismissAction: { },
				   tapUrlAction: { _ in })
}

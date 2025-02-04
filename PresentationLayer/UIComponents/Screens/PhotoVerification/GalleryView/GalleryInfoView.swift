//
//  GalleryInfoView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/2/25.
//

import SwiftUI

struct GalleryInfoView: View {
	let infoText: String

    var body: some View {
		HStack(spacing: CGFloat(.smallSpacing)) {
			Text(FontIcon.infoCircle.rawValue)
				.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
				.foregroundStyle(Color(colorEnum: .wxmPrimary))
				.fixedSize()

			Text(infoText)
				.font(.system(size: CGFloat(.normalFontSize)))
				.foregroundStyle(Color(colorEnum: .text))
				.fixedSize(horizontal: false, vertical: true)
		}
		.padding(CGFloat(.smallToMediumSidePadding))
		.background {
			Capsule().fill(Color(colorEnum: .layer1))
		}
    }
}

#Preview {
	GalleryInfoView(infoText: LocalizableString.PhotoVerification.maxLimitPhotosInfo(3).localized)
}

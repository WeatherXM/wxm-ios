//
//  GalleryView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/12/24.
//

import SwiftUI

struct GalleryView: View {
	@StateObject var viewModel: GalleryViewModel
	
    var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()
			VStack(spacing: 0.0) {
				HStack(spacing: CGFloat(.mediumSpacing)) {
					Button {

					} label: {
						Text(FontIcon.xmark.rawValue)
							.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
							.foregroundStyle(.text)
					}

					VStack(alignment: .leading, spacing: CGFloat(.minimumSpacing)) {
						Text(LocalizableString.PhotoVerification.stationPhotos.localized)
							.font(.system(size: CGFloat(.titleFontSize)))
							.foregroundStyle(Color(colorEnum: .text))

						if let subtitle = viewModel.subtitle {
							Text(subtitle)
								.font(.system(size: CGFloat(.caption)))
								.foregroundStyle(Color(colorEnum: .darkGrey))
						}
					}

					Spacer()

					Button {

					} label: {
						Text(LocalizableString.PhotoVerification.upload.localized)
					}
					.buttonStyle(WXMCapsuleButtonStyle())

				}
				.padding(CGFloat(.mediumSidePadding))
				.background(Color(colorEnum: .top))

				GeometryReader { proxy in
					Text(verbatim: "hrgeb")
				}
			}
		}
    }
}

#Preview {
	GalleryView(viewModel: ViewModelsFactory.getGalleryViewModel())
}

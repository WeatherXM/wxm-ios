//
//  GalleryView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/12/24.
//

import SwiftUI
import NukeUI

struct GalleryView: View {
	@Environment(\.dismiss) private var dismiss
	@StateObject var viewModel: GalleryViewModel
	
    var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()
			VStack(spacing: 0.0) {
				HStack(spacing: CGFloat(.mediumSpacing)) {
					Button {
						dismiss()
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

				VStack(spacing: CGFloat(.largeSpacing)) {
					galleryScroller

					HStack {
						Button {

						} label: {
							Text(FontIcon.trash.rawValue)
								.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
								.foregroundStyle(Color(colorEnum: .error))
								.padding(CGFloat(.mediumSidePadding))
								.background(Circle().fill(Color(colorEnum: .layer1)))
						}
						.buttonStyle(WXMButtonOpacityStyle())

						Spacer()

						Button {

						} label: {
							Text(LocalizableString.PhotoVerification.instructions.localized)
								.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .text))
								.padding(CGFloat(.mediumSidePadding))
								.background(Capsule().fill(Color(colorEnum: .layer1)))
						}
						.buttonStyle(WXMButtonOpacityStyle())
					}
				}
				.padding(.horizontal, CGFloat(.defaultSidePadding))
				.padding(.bottom, CGFloat(.defaultSidePadding))
			}
		}
		.navigationBarHidden(true)
    }
}

private extension GalleryView {
	@ViewBuilder
	var galleryScroller: some View {
		ScrollView(.horizontal) {
			HStack(spacing: CGFloat(.smallSpacing)) {
				ForEach(viewModel.images, id: \.self) { imageUrl in
					LazyImage(url: URL(string: imageUrl)) { state in
						if let image = state.image {
							image
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(width: 50.0, height: 70.0)
								.cornerRadius(CGFloat(.buttonCornerRadius))
						} else {
							ProgressView()
								.frame(width: 50.0, height: 70.0)
						}
					}
				}
				Button {
					viewModel.handlePlusButtonTap()
				} label: {
					Text(FontIcon.plus.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
						.foregroundStyle(Color(colorEnum: .wxmPrimary))
						.frame(width: 50.0, height: 70.0)
						.background(Color(colorEnum: .layer1))
						.cornerRadius(CGFloat(.buttonCornerRadius))
				}
			}
		}
	}
}

#Preview {
	GalleryView(viewModel: ViewModelsFactory.getGalleryViewModel())
}

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
					if let selectedImage = viewModel.selectedImage {
						LazyImage(url: URL(string: selectedImage)) { state in
							if let image = state.image {
								image
									.resizable()
									.aspectRatio(contentMode: .fill)
									.frame(width: proxy.size.width - 2 * CGFloat(.defaultSidePadding),
										   height: proxy.size.height - 2 * CGFloat(.defaultSidePadding),
										   alignment: .center)
									.clipped()
									.position(x: proxy.frame(in: .local).midX,
											  y: proxy.frame(in: .local).midY)
							} else {
								ProgressView()
									.position(x: proxy.frame(in: .local).midX,
											  y: proxy.frame(in: .local).midY)
							}
						}
					} else {
						noImageView
							.frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
					}
				}
				.animation(.easeIn(duration: 0.3), value: viewModel.selectedImage)

				VStack(spacing: CGFloat(.largeSpacing)) {
					galleryScroller

					HStack {
						Button {
							viewModel.handleDeleteButtonTap()
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
							viewModel.handleInstructionsButtonTap()
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
		.sheet(isPresented: $viewModel.showInstructions) {
			PhotoIntroView(viewModel: ViewModelsFactory.getPhotoInstructionsViewModel())
		}
    }
}

private extension GalleryView {
	@ViewBuilder
	var galleryScroller: some View {
		let normalSize = CGSize(width: 50.0, height: 70.0)
		let selectedSize = CGSize(width: 62.0, height: 88.0)

		GeometryReader { proxy in
			ScrollView(.horizontal) {
				ZStack {
					Color.clear
						.frame(width: proxy.size.width)
					HStack(spacing: CGFloat(.smallSpacing)) {
						ForEach(viewModel.images, id: \.self) { imageUrl in
							let isSelected = viewModel.selectedImage == imageUrl
							let size = isSelected ? selectedSize : normalSize

							Button {
								viewModel.selectedImage = imageUrl
							} label: {
								LazyImage(url: URL(string: imageUrl)) { state in
									if let image = state.image {
										image
											.resizable()
											.aspectRatio(contentMode: .fill)
											.frame(width: size.width, height: size.height)
											.cornerRadius(CGFloat(.buttonCornerRadius))
											.indication(show: .constant(isSelected),
														borderColor: Color(colorEnum: .wxmPrimary),
														bgColor: .clear,
														cornerRadius: CGFloat(.buttonCornerRadius),
														content: { EmptyView() })
									} else {
										ProgressView()
											.frame(width: normalSize.width, height: normalSize.height)
									}
								}
							}
						}

						Button {
							viewModel.handlePlusButtonTap()
						} label: {
							Text(FontIcon.plus.rawValue)
								.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
								.foregroundStyle(Color(colorEnum: .wxmPrimary))
								.frame(width: normalSize.width, height: normalSize.height)
								.background(Color(colorEnum: .layer1))
								.cornerRadius(CGFloat(.buttonCornerRadius))
						}
					}
				}
			}
			.scrollIndicators(.hidden)
			.animation(.easeIn(duration: 0.1), value: viewModel.selectedImage)
		}
		.frame(height: selectedSize.height)
	}

	@ViewBuilder
	var noImageView: some View {
		Text(verbatim: "Empty")
	}
}

#Preview {
	GalleryView(viewModel: ViewModelsFactory.getGalleryViewModel())
}

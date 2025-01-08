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
						viewModel.handleBackButtonTap(dismissAction: dismiss)
					} label: {
						Text(viewModel.backButtonIcon.rawValue)
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
						viewModel.handleUploadButtonTap()
					} label: {
						Text(LocalizableString.PhotoVerification.upload.localized)
					}
					.buttonStyle(WXMCapsuleButtonStyle())
					.disabled(!viewModel.isUploadButtonEnabled)

				}
				.padding(CGFloat(.mediumSidePadding))
				.background(Color(colorEnum: .top))

				Group {
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
								.frame(width: proxy.size.width * 0.85, height: proxy.size.height, alignment: .center)
								.position(x: proxy.frame(in: .local).midX,
										  y: proxy.frame(in: .local).midY)

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
							.disabled(viewModel.selectedImage == nil)

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
				.iPadMaxWidth()
			}
			.spinningLoader(show: $viewModel.showLoading,
							title: viewModel.loadingTitle,
							subtitle: viewModel.loadingSubtitle,
							hideContent: true)
			.success(show: $viewModel.showUploadStartedSuccess, obj: viewModel.uploadStartedObject)
		}
		.navigationBarHidden(true)
		.sheet(isPresented: $viewModel.showInstructions) {
			PhotoIntroView(viewModel: ViewModelsFactory.getPhotoInstructionsViewModel(deviceId: viewModel.deviceId))
		}
		.task {
			viewModel.viewLoaded()
		}
		.wxmShareDialog(show: $viewModel.showShareSheet, text: "", files: viewModel.shareFileUrls ?? [])
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
														borderWidth: 2.0,
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

						if viewModel.isPlusButtonVisible {
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
							.buttonStyle(WXMButtonOpacityStyle())
							.disabled(!viewModel.isPlusButtonEnabled)
							.transition(.opacity)
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
		if viewModel.isCameraDenied {
			noPermissionView
		} else {
			emptyImagesView
		}
	}

	@ViewBuilder
	var emptyImagesView: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			Text(LocalizableString.PhotoVerification.tapThePlusButton.localized)
				.foregroundStyle(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
			Text(LocalizableString.PhotoVerification.yourCameraWillOpen.localized)
				.foregroundStyle(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.mediumFontSize)))
		}
	}

	@ViewBuilder
	var noPermissionView: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			Text(LocalizableString.PhotoVerification.allowAccess.localized)
				.foregroundStyle(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
				.multilineTextAlignment(.center)

			Button {
				viewModel.handleOpenSettingsTap()
			} label: {
				Text(LocalizableString.PhotoVerification.openSettings.localized)
			}
			.buttonStyle(WXMButtonStyle.filled())
		}
	}
}

#Preview {
	GalleryView(viewModel: ViewModelsFactory.getGalleryViewModel(deviceId: "",
																 images: [],
																 isNewVerification: true))
}

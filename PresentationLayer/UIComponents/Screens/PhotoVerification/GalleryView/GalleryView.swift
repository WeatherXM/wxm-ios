//
//  GalleryView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/12/24.
//

import SwiftUI
import NukeUI
import Toolkit

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
						viewModel.handleUploadButtonTap(dismissAction: dismiss)
					} label: {
						Text(LocalizableString.PhotoVerification.upload.localized)
					}
					.buttonStyle(WXMCapsuleButtonStyle())
					.disabled(!viewModel.isUploadButtonEnabled)

				}
				.padding(CGFloat(.mediumSidePadding))
				.background(Color(colorEnum: .top))
				.shimmerLoader(show: $viewModel.showShimmerLoading,
							   position: .bottom)

				Group {
					GeometryReader { proxy in
						if let selectedImage = viewModel.selectedImage {
							if let remoteUrl = selectedImage.remoteUrl {
								LazyImage(url: URL(string: remoteUrl)) { state in
									if let image = state.image {
										image
											.resizable()
											.aspectRatio(contentMode: .fit)
											.frame(width: proxy.size.width - 2 * CGFloat(.defaultSidePadding),
												   height: proxy.size.height - 2 * CGFloat(.defaultSidePadding),
												   alignment: .center)
											.clipped()
											.contentShape(Rectangle())
											.position(x: proxy.frame(in: .local).midX,
													  y: proxy.frame(in: .local).midY)
									} else {
										ProgressView()
											.position(x: proxy.frame(in: .local).midX,
													  y: proxy.frame(in: .local).midY)
									}
								}
							} else if let image = selectedImage.image {
								image
									.resizable()
									.aspectRatio(contentMode: .fit)
									.frame(width: proxy.size.width - 2 * CGFloat(.defaultSidePadding),
										   height: proxy.size.height - 2 * CGFloat(.defaultSidePadding),
										   alignment: .center)
									.clipped()
									.contentShape(Rectangle())
									.position(x: proxy.frame(in: .local).midX,
											  y: proxy.frame(in: .local).midY)
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

						HStack(spacing: CGFloat(.defaultSpacing)) {
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

							Button {
								viewModel.handleGalleryButtonTap()
							} label: {
								Text(FontIcon.image.rawValue)
									.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
									.foregroundStyle(Color(colorEnum: .text))
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
				.iPadMaxWidth()
			}
			.spinningLoader(show: $viewModel.showLoading,
							title: viewModel.loadingTitle,
							subtitle: viewModel.loadingSubtitle,
							hideContent: true)
			.success(show: $viewModel.showUploadStartedSuccess, obj: viewModel.uploadStartedObject)
			.fail(show: $viewModel.showFail, obj: viewModel.failObject)
		}
		.navigationBarHidden(true)
		.sheet(isPresented: $viewModel.showInstructions) {
			PhotoIntroView(viewModel: ViewModelsFactory.getPhotoInstructionsViewModel(deviceId: viewModel.deviceId))
		}
		.task {
			viewModel.viewLoaded()
		}
		.wxmShareDialog(show: $viewModel.showShareSheet,
						text: "",
						images: viewModel.shareImages ?? [],
						disablePopοver: true)
		.onAppear {
			viewModel.handleOnAppear()
		}
    }
}

extension GalleryView {
	enum ImageSource {
		case camera
		case library

		var sourceValue: String {
			switch self {
				case .camera:
					return "wxm-device-photo-camera"
				case .library:
					return "wxm-device-photo-library"
			}
		}

		var parameterValue: ParameterValue {
			switch self {
				case .camera:
					return .camera
				case .library:
					return .gallery
			}
		}
	}

	struct GalleryImage: Identifiable, Equatable {
		let remoteUrl: String?
		let uiImage: UIImage?
		let metadata: NSDictionary?
		let source: ImageSource?

		var id: String {
			remoteUrl ?? "\(uiImage.hashValue)"
		}

		var image: Image? {
			guard let uiImage else { return nil }
			return Image(uiImage: uiImage)
		}

		var isRmemoteImage: Bool {
			remoteUrl != nil
		}
	}
}

private extension GalleryView {
	@ViewBuilder
	var galleryScroller: some View {
		let normalWidth = 50.0
		let normalHeight = 70.0
		let selectedScale: CGFloat = 1.25
		let selectedSize = CGSize(width: normalWidth * selectedScale, height: normalHeight * selectedScale)

		GeometryReader { proxy in
			ScrollView(.horizontal) {
				ZStack {
					Color.clear
						.frame(width: proxy.size.width)
					HStack(spacing: CGFloat(.smallSpacing)) {
						ForEach(viewModel.images) { image in
							let isSelected = viewModel.selectedImage == image

							Group {
								if let imageUrl = image.remoteUrl {
									LazyImage(url: URL(string: imageUrl)) { state in
										if let image = state.image {
											image
												.resizable()
												.aspectRatio(contentMode: .fill)
												.frame(width: normalWidth, height: normalHeight)
												.cornerRadius(CGFloat(.buttonCornerRadius))
												.contentShape(Rectangle())
												.indication(show: .constant(isSelected),
															borderColor: Color(colorEnum: .wxmPrimary),
															borderWidth: 2.0,
															bgColor: .clear,
															cornerRadius: CGFloat(.buttonCornerRadius),
															content: { EmptyView() })
										} else {
											ProgressView()
												.frame(width: normalWidth, height: normalHeight)
										}
									}
								} else if let imageView = image.image {
									imageView
										.resizable()
										.aspectRatio(contentMode: .fill)
										.frame(width: normalWidth, height: normalHeight)
										.contentShape(Rectangle())
										.cornerRadius(CGFloat(.buttonCornerRadius))
										.indication(show: .constant(isSelected),
													borderColor: Color(colorEnum: .wxmPrimary),
													borderWidth: 2.0,
													bgColor: .clear,
													cornerRadius: CGFloat(.buttonCornerRadius),
													content: { EmptyView() })
								} else {
									EmptyView()
								}
							}
							.onTapGesture {
								viewModel.selectedImage = image
							}
							.frame(width: normalWidth, height: normalHeight)
							.scaleEffect(isSelected ? selectedScale : 1.0)
							.animation(.easeIn(duration: 0.1), value: viewModel.selectedImage)
						}

						Button {
							viewModel.handlePlusButtonTap()
						} label: {
							Text(FontIcon.plus.rawValue)
								.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
								.foregroundStyle(Color(colorEnum: .wxmPrimary))
								.frame(width: normalWidth, height: normalHeight)
								.background(Color(colorEnum: .layer1))
								.cornerRadius(CGFloat(.buttonCornerRadius))
						}
						.buttonStyle(WXMButtonOpacityStyle())
						.disabled(!viewModel.isPlusButtonEnabled)
					}
				}
			}.modify { view in
				if #available(iOS 16.4, *) {
					view
						.scrollBounceBehavior(.basedOnSize, axes: .horizontal)
				} else {
					view
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
																 images: ["https://i0.wp.com/weatherxm.com/wp-content/uploads/2023/12/Home-header-image-1200-x-1200-px-2.png?w=1200&ssl=1",
																		 "https://i0.wp.com/weatherxm.com/wp-content/uploads/2024/09/Home-header-image-1200-x-1200-px-15-1.png?w=1200&ssl=1",
																		 "https://i0.wp.com/weatherxm.com/wp-content/uploads/2024/05/Untitled-design-_41_.webp?w=700&ssl=1"],
																 isNewVerification: true))
}

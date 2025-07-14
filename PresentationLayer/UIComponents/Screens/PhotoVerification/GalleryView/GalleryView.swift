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

				GalleryImagesView(viewModel: viewModel.galleryImagesViewModel)
			}
			.spinningLoader(show: $viewModel.showLoading,
							title: viewModel.loadingTitle,
							subtitle: viewModel.loadingSubtitle,
							hideContent: true)
			.success(show: $viewModel.showUploadStartedSuccess, obj: viewModel.uploadStartedObject)
			.fail(show: $viewModel.showFail, obj: viewModel.failObject)
		}
		.navigationBarHidden(true)
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

#Preview {
	GalleryView(viewModel: ViewModelsFactory.getGalleryViewModel(deviceId: "",
																 images: ["https://i0.wp.com/weatherxm.com/wp-content/uploads/2023/12/Home-header-image-1200-x-1200-px-2.png?w=1200&ssl=1",
																		 "https://i0.wp.com/weatherxm.com/wp-content/uploads/2024/09/Home-header-image-1200-x-1200-px-15-1.png?w=1200&ssl=1",
																		 "https://i0.wp.com/weatherxm.com/wp-content/uploads/2024/05/Untitled-design-_41_.webp?w=700&ssl=1"],
																 isNewVerification: true))
}

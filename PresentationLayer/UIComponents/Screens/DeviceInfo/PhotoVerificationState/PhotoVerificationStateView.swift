//
//  PhotoVerificationStateView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 18/12/24.
//

import SwiftUI
import NukeUI

struct PhotoVerificationStateView: View {
	@StateObject var viewModel: PhotoVerificationStateViewModel

	var body: some View {
		switch viewModel.state {
			case .content(let photos):
				photosView(photos: photos)
			case .uploading(let progress):
				uploadingView(progress: progress)
			case .empty:
				Text(verbatim: "Empty")
		}
    }
}

extension PhotoVerificationStateView {
	enum State {
		case content(photos: [URL])
		case uploading(progress: CGFloat)
		case empty
	}

	@ViewBuilder
	func photosView(photos: [URL]) -> some View {
		let last = photos.last
		LazyVGrid(columns: [.init(spacing: CGFloat(.smallSpacing)), .init()]) {
			ForEach(photos, id: \.self) { url in
				Color.clear
					.aspectRatio(1.0, contentMode: .fit)
					.overlay {
						LazyImage(url: url) { state in
							if let image = state.image {
								image
									.resizable()
									.aspectRatio(contentMode: .fill)
									.clipped()
							} else {
								ProgressView()
							}
						}
					}
					.overlay {
						let isLast = url == last
						if isLast, viewModel.morePhotosCount > 0 {
							ZStack {
								Text("+\(viewModel.morePhotosCount)")
									.font(.system(size: CGFloat(.XLTitleFontSize), weight: .bold))
									.foregroundStyle(Color(colorEnum: .textInverse))

								Color.black.opacity(0.6)
							}
						}
					}
					.cornerRadius(CGFloat(.buttonCornerRadius))
			}
		}
	}

	@ViewBuilder
	func uploadingView(progress: CGFloat) -> some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			HStack(alignment: .bottom, spacing: CGFloat(.smallSpacing)) {
				Text(LocalizableString.percentage(Float(progress)).localized)
					.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Text(LocalizableString.PhotoVerification.uploading.localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			Button {
				viewModel.handleCancelUploadTap()
			} label: {
				Text(LocalizableString.PhotoVerification.cancelUpload.localized)
			}
			.buttonStyle(WXMButtonStyle())
		}
	}
}

#Preview {
	PhotoVerificationStateView(viewModel: ViewModelsFactory.getPhotoVerificationStateViewModel(deviceId: ""))
}

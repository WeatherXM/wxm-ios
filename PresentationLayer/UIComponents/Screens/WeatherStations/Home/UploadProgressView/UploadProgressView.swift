//
//  UploadProgressView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/12/24.
//

import SwiftUI
import Toolkit

struct UploadProgressView: View {
	@Environment(\.colorScheme) var colorScheme
	let state: UploadState
	let stationName: String
	let tapAction: VoidCallback
	let shouldDismissAction: VoidCallback

	private let iconDimensions: CGFloat = 50.0
	@State private var offset: CGFloat = 0.0
	@State private var size: CGSize = .zero

	var uploadingAnimation: AnimationsEnums {
		switch colorScheme {
			case .dark:
				return .uploadingDark
			case .light:
				return .uploadingLight
			@unknown default:
				return .uploadingLight
		}
	}

	var body: some View {
		ZStack {
			HStack(spacing: CGFloat(.smallToMediumSpacing)) {
				sideIcon
					.frame(width: iconDimensions, height: iconDimensions)

				VStack(spacing: CGFloat(.minimumSpacing)) {
					mainContent
				}
			}
			.WXMCardStyle()
			.wxmShadow()
			.offset(x: offset)
		}
		.sizeObserver(size: $size)
		.gesture(DragGesture(minimumDistance: 0).onChanged { value in
			offset = min(0.0, value.translation.width)
		}.onEnded { value in
			let shouldDimiss = abs(offset) >= size.width / 2
			withAnimation(.easeIn(duration: 0.2)) {
				offset = shouldDimiss ? -2.0 * size.width : 0.0
			}

			if shouldDimiss {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					shouldDismissAction()
				}
			}
		})
		.simultaneousGesture(TapGesture().onEnded {
			tapAction()
		})
    }
}

extension UploadProgressView {
	enum UploadState: Equatable {
		case uploading(progress: Float)
		case completed
		case failed
	}

}

private extension UploadProgressView {
	@ViewBuilder
	var mainContent: some View {
		switch state {
			case .uploading(let progress):
				HStack(alignment: .bottom, spacing: CGFloat(.smallSpacing)) {
					Text(LocalizableString.percentage(progress).localized)
						.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
						.foregroundStyle(Color(colorEnum: .text))

					Text(LocalizableString.PhotoVerification.uploading.localized)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundStyle(Color(colorEnum: .text))

					Spacer()
				}

				VStack(spacing: CGFloat(.minimumSpacing)) {
					ProgressView(value: progress, total: 100.0)
						.tint(Color(colorEnum: .wxmPrimary))
						.animation(.easeOut(duration: 0.3), value: progress)

					HStack {
						Text(stationName)
							.font(.system(size: CGFloat(.caption)))
							.foregroundStyle(Color(colorEnum: .darkGrey))

						Spacer()
					}
				}

			case .completed:
				HStack(alignment: .bottom, spacing: CGFloat(.smallSpacing)) {
					Text(LocalizableString.percentage(100).localized)
						.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
						.foregroundStyle(Color(colorEnum: .text))

					Text(LocalizableString.completed.localized)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundStyle(Color(colorEnum: .text))

					Spacer()
				}

				VStack(spacing: CGFloat(.minimumSpacing)) {
					ProgressView(value: 100.0, total: 100.0)
						.tint(Color(colorEnum: .wxmPrimary))

					HStack {
						Text(stationName)
							.font(.system(size: CGFloat(.caption)))
							.foregroundStyle(Color(colorEnum: .darkGrey))

						Spacer()
					}
				}

			case .failed:
				HStack(alignment: .bottom, spacing: CGFloat(.smallSpacing)) {
					Text(LocalizableString.PhotoVerification.uploadFailedTapToRetry.localized)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundStyle(Color(colorEnum: .text))

					Spacer()
				}

				HStack {
					Text(stationName)
						.font(.system(size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .darkGrey))

					Spacer()
				}
		}
	}

	@ViewBuilder
	var sideIcon: some View {
		switch state {
			case .uploading:
				LottieView(animationCase: uploadingAnimation.animationString,
						   loopMode: .loop)
			case .completed:
				LottieView(animationCase: AnimationsEnums.uploadCompleted.animationString,
						   loopMode: .playOnce)
			case .failed:
				Text(FontIcon.rotateRight.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.XXLTitleFontSize)))
					.foregroundStyle(Color(colorEnum: .wxmPrimary))
		}
	}
}

#Preview {
	VStack {
		UploadProgressView(state: .uploading(progress: 59.0),
						   stationName: "Test name",
						   tapAction: {}) {}

		UploadProgressView(state: .completed,
						   stationName: "Test name",
						   tapAction: {}) {}

		UploadProgressView(state: .failed,
						   stationName: "Test name",
						   tapAction: {}) {}

	}
}

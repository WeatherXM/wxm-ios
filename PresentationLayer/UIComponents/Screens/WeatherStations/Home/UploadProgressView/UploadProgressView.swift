//
//  UploadProgressView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/12/24.
//

import SwiftUI

struct UploadProgressView: View {
	@Environment(\.colorScheme) var colorScheme
	let state: State
	let stationName: String


	var showTipView = true

	private let iconDimensions: CGFloat = 50

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
		HStack(spacing: CGFloat(.smallToMediumSpacing)) {
			sideIcon
				.frame(width: iconDimensions, height: iconDimensions)

			VStack(spacing: CGFloat(.minimumSpacing)) {
				mainContent
			}
		}
		.WXMCardStyle()
		.wxmShadow()
    }
}

extension UploadProgressView {
	enum State {
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
						   stationName: "Test name")

		UploadProgressView(state: .completed,
						   stationName: "Test name")

		UploadProgressView(state: .failed,
						   stationName: "Test name")

	}
}

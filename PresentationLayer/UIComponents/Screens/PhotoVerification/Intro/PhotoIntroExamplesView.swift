//
//  PhotoIntroExamplesView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/12/24.
//

import SwiftUI

struct PhotoIntroExamplesView: View {
	var isDestructive: Bool = false
	let containerWidth: CGFloat
	let title: String
	let examples: [Example]

	private var bulletIcon: FontIcon {
		isDestructive ? .xmark : .check
	}

	private var titleIcon: FontIcon {
		isDestructive ? .circleXmark : .circleCheck
	}

	private var bulletColor: ColorEnum {
		isDestructive ? .error : .success
	}

	private var tintColor: ColorEnum {
		isDestructive ? .errorTint : .successTint
	}

	private var scaleFactor: CGFloat {
		isDestructive ? 0.5 : 0.8
	}

	private var imageRatio: CGFloat {
		isDestructive ? 0.8 : 1.3
	}

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(title)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))
					.fixedSize(horizontal: false, vertical: true)

				Text(titleIcon.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.caption)))
					.foregroundStyle(Color(colorEnum: bulletColor))
					.fixedSize()

				Spacer()
			}

			ScrollView(.horizontal) {
				HStack(alignment: .top, spacing: CGFloat(.smallToMediumSpacing)) {
					ForEach(examples) { example in
						exampleView(example)
					}
				}
			}
			.disableScrollClip()
			.scrollIndicators(.hidden)
		}
		.padding(.vertical, CGFloat(.mediumSidePadding))
		.padding(.horizontal, CGFloat(.mediumToLargeSidePadding))
		.background {
			Color(colorEnum: tintColor)
		}
    }
}

extension PhotoIntroExamplesView {
	struct Example: Identifiable {
		var id: AssetEnum {
			image
		}
		let image: AssetEnum
		let bullets: [String]
	}
}

private extension PhotoIntroExamplesView {
	@ViewBuilder
	func exampleView(_ example: Example) -> some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			Image(asset: example.image)
				.resizable()
				.aspectRatio(imageRatio, contentMode: .fill)
				.frame(height: 0.6 * containerWidth)
				.cornerRadius(CGFloat(.smallCornerRadius))
			
			ForEach(example.bullets, id: \.self) { text in
				HStack(alignment: .top, spacing: CGFloat(.smallSpacing)) {
					Text(bulletIcon.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: bulletColor))
						.fixedSize()

					Text(text)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundStyle(Color(colorEnum: .text))
						.fixedSize(horizontal: false, vertical: true)

					Spacer()
				}
			}
		}
		.frame(width: scaleFactor * containerWidth)
		.clipped()
	}
}

#Preview {
	GeometryReader { proxy in
		PhotoIntroExamplesView(isDestructive: true,
							   containerWidth: proxy.size.width,
							   title: LocalizableString.PhotoVerification.yourPhotoShouldLook.localized,
							   examples: [.init(image: .recommendedInstallation0,
												bullets: [LocalizableString.PhotoVerification.checkFromTheRainGauge.localized]),
										  .init(image: .recommendedInstallation1,
														   bullets: [LocalizableString.PhotoVerification.checkFromTheRainGauge.localized,
																	 LocalizableString.PhotoVerification.checkClearView.localized])])
		.padding()
	}
}

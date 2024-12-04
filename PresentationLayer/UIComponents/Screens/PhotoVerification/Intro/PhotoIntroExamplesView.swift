//
//  PhotoIntroExamplesView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/12/24.
//

import SwiftUI

struct PhotoIntroExamplesView: View {
	let containerWidth: CGFloat
	let title: String
	let examples: [Example]

    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			HStack {
				Text(title)
					.font(.system(size: CGFloat(.mediumFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))
					.fixedSize(horizontal: false, vertical: true)

				Text(FontIcon.circleCheck.rawValue)
					.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.caption)))
					.foregroundStyle(Color(colorEnum: .success))
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
		.WXMCardStyle(backgroundColor: Color(colorEnum: .successTint))
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
				.aspectRatio(1.0,contentMode: .fit)
				.cornerRadius(CGFloat(.smallCornerRadius))

			ForEach(example.bullets, id: \.self) { text in
				HStack(alignment: .top, spacing: CGFloat(.smallSpacing)) {
					Text(FontIcon.check.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.caption)))
						.foregroundStyle(Color(colorEnum: .success))
						.fixedSize()

					Text(text)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundStyle(Color(colorEnum: .text))
						.fixedSize(horizontal: false, vertical: true)

					Spacer()
				}
			}
		}
		.frame(width: 0.8 * containerWidth)
	}
}

#Preview {
	GeometryReader { proxy in
		PhotoIntroExamplesView(containerWidth: proxy.size.width,
							   title: LocalizableString.PhotoVerification.yourPhotoShouldLook.localized,
							   examples: [.init(image: .recommendedInstallation0,
												bullets: [LocalizableString.PhotoVerification.checkFromTheRainGauge.localized]),
										  .init(image: .recommendedInstallation1,
														   bullets: [LocalizableString.PhotoVerification.checkFromTheRainGauge.localized,
																	 LocalizableString.PhotoVerification.checkClearView.localized])])
		.padding()
	}
}

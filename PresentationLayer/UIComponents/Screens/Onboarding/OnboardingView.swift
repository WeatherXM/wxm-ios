//
//  OnboardingView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/25.
//

import SwiftUI

struct OnboardingView: View {
	let slides: [Slide] = [Slide(image: .onboardingImage0,
								 title: LocalizableString.Onboarding.forecastForEveryCorner.localized),
						   Slide(image: .onboardingImage1,
								 title: LocalizableString.Onboarding.liveTransparentNetwork.localized),
						   Slide(image: .onboardingImage2,
								 title: LocalizableString.Onboarding.contributeAndEarn.localized)]
    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			Image(asset: .weatherXMLogoText)
			Text(LocalizableString.Onboarding.title.localized)
				.foregroundStyle(Color(colorEnum: .textDarkStable))
				.font(.system(size: CGFloat(.smallTitleFontSize)))

			GeometryReader { _ in
				ScrollView(.horizontal) {
					HStack {
						ForEach(slides) { slide in
							cardView(slide: slide)
						}
					}
				}
				.background(Color(colorEnum: .blueTint))
			}

			VStack(spacing: CGFloat(.defaultSpacing)) {
				Button {

				} label: {
					Text(LocalizableString.Onboarding.signUpButtonTitle.localized)
						.foregroundStyle(Color(colorEnum: .darkBg))
						.font(.system(size: CGFloat(.mediumFontSize),
									  weight: .bold))
				}
				.buttonStyle(WXMButtonStyle(fillColor: .textWhite,
											strokeColor: .textWhite,
											cornerRadius: 25.0))

				Button {

				} label: {
					Text(LocalizableString.Onboarding.exploreTheAppButtonTitle.localized)
						.foregroundStyle(Color(colorEnum: .textWhite))
						.font(.system(size: CGFloat(.mediumFontSize),
									  weight: .bold))
				}
				.buttonStyle(.plain)
			}
			.padding(.horizontal, CGFloat(.largeSidePadding))
		}
		.padding(.vertical, CGFloat(.largeSidePadding))
    }
}

extension OnboardingView {
	struct Slide: Identifiable {
		var id: String {
			title + image.rawValue
		}

		let image: AssetEnum
		let title: String
	}
}

private extension OnboardingView {
	@ViewBuilder
	func cardView(slide: Slide) -> some View {
		Image(asset: slide.image)
			.resizable()
			.aspectRatio(0.54, contentMode: .fill)
			.background(Color(colorEnum: .error))
			.overlay {
				VStack {
					Spacer()

					HStack {
						Spacer()

						Text(slide.title)
							.multilineTextAlignment(.center)
							.font(.system(size: CGFloat(.largeTitleFontSize),
										  weight: .bold))
							.foregroundStyle(Color(colorEnum: .textWhite))
							.padding(CGFloat(.largeSidePadding))

						Spacer()
					}
					.background {
						BackdropBlurView(radius: 15.0)
					}

				}
			}
			.clipShape(.rect(cornerRadius: CGFloat(.cardCornerRadius)))
			.wxmShadow()
	}
}

#Preview {
	ZStack {
		Color(colorEnum: .bg)
			.ignoresSafeArea()
		OnboardingView()
	}
}

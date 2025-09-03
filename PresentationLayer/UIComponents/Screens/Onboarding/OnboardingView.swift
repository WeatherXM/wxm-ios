//
//  OnboardingView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/25.
//

import SwiftUI
import SwiftUIIntrospect

struct OnboardingView: View {
	let slides: [Slide] = [Slide(image: .onboardingImage3,
								 title: LocalizableString.Onboarding.forecastForEveryCorner.localized),
						   Slide(image: .onboardingImage1,
								 title: LocalizableString.Onboarding.liveTransparentNetwork.localized),
						   Slide(image: .onboardingImage2,
								 title: LocalizableString.Onboarding.contributeAndEarn.localized),
						   Slide(image: .onboardingImage3,
								 title: LocalizableString.Onboarding.communityPowered.localized)]
    var body: some View {
		VStack(spacing: CGFloat(.smallSpacing)) {
			Image(asset: .weatherXMLogoText)
			Text(LocalizableString.Onboarding.title.localized)
				.foregroundStyle(Color(colorEnum: .textDarkStable))
				.font(.system(size: CGFloat(.smallTitleFontSize)))

			GeometryReader { proxy in
				slidesScroller(containerWidth: proxy.size.width)
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
	func slidesScroller(containerWidth: CGFloat) -> some View {
		ScrollView(.horizontal) {
			LazyHStack(spacing: CGFloat(.defaultSpacing)) {
				ForEach(slides) { slide in
					cardView(slide: slide)
						.frame(width: 0.8 * containerWidth)
				}
			}
			.padding(.horizontal, 0.1 * containerWidth)
			.modify { view in
				if #available(iOS 17.0, *) {
					view.scrollTargetLayout()
				} else {
					view
				}
			}
		}
		.modify { view in
			if #available(iOS 17.0, *) {
				view.scrollTargetBehavior(.viewAligned)
			} else {
				view
					.pagingEnabled(true)
			}
		}
		.scrollIndicators(.hidden)
		.background(Color(colorEnum: .blueTint))
	}

	@ViewBuilder
	func cardView(slide: Slide) -> some View {
		Image(asset: slide.image)
			.resizable()
			.aspectRatio(contentMode: .fill)
			.overlay {
				VStack {
					Spacer()

					ZStack {
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
					}
					.background {
						BackdropBlurView(radius: 15.0)
							.padding(.horizontal, -20)
							.padding(.bottom, -20)
					}
				}
			}
			.clipShape(.rect(cornerRadius: CGFloat(.cardCornerRadius)))
			.wxmShadow()
	}
}

extension View {
	func pagingEnabled(_ isPagingEnabled: Bool) -> some View {
		self.introspect(.scrollView, on: .iOS(.v16)) { view in
			view.isPagingEnabled = isPagingEnabled
		}
	}
}

#Preview {
	ZStack {
		Color(colorEnum: .bg)
			.ignoresSafeArea()
		OnboardingView()
	}
}

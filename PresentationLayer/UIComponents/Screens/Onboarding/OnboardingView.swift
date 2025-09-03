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

	@State private var currentSlideId: String?

	var body: some View {
		ZStack {
			if let currentSlide = slides.first(where: { $0.id == currentSlideId}) {
				Color.clear.overlay {
					Image(asset: currentSlide.image)
						.resizable()
						.interpolation(.none)
						.aspectRatio(contentMode: .fill)
						.blur(radius: 100)
						.clipped()
						.ignoresSafeArea()
						.animation(.easeIn, value: currentSlideId)
				}
			}

			VStack(spacing: CGFloat(.largeSpacing)) {
				Image(asset: .weatherXMLogoText)
				Text(LocalizableString.Onboarding.title.localized)
					.foregroundStyle(Color(colorEnum: .textDarkStable))
					.font(.system(size: CGFloat(.smallTitleFontSize)))

				GeometryReader { proxy in
					slidesScroller(containerSize: proxy.size)
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
			.padding(.top, CGFloat(.defaultSidePadding))
			.padding(.bottom, CGFloat(.largeSidePadding))
		}
		.task {
			currentSlideId = slides.first?.id
		}
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
	func slidesScroller(containerSize: CGSize) -> some View {
		if #available(iOS 17.0, *) {
			ScrollView(.horizontal) {
				LazyHStack(spacing: 0.05 * containerSize.width) {
					ForEach(slides) { slide in
						cardView(slide: slide,
								 height: containerSize.height)
							.frame(width: 0.8 * containerSize.width)
							.id(slide.id)
					}
				}
				.padding(.horizontal, 0.1 * containerSize.width)
				.scrollTargetLayout()
			}
			.scrollTargetBehavior(.viewAligned)
			.scrollPosition(id: $currentSlideId)
			.scrollIndicators(.hidden)
		} else {
			ScrollView(.horizontal) {
				LazyHStack(spacing: CGFloat(.defaultSpacing)) {
					ForEach(slides) { slide in
						cardView(slide: slide,
								 height: containerSize.height)
							.frame(width: 0.8 * containerSize.width,
								   height: containerSize.height)
					}
				}
				.padding(.horizontal, 0.1 * containerSize.width)
			}
			.scrollIndicators(.hidden)
			.background(Color(colorEnum: .error))
		}
	}

	@ViewBuilder
	func cardView(slide: Slide, height: CGFloat) -> some View {
		ZStack {
			Image(asset: slide.image)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(height: height)
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

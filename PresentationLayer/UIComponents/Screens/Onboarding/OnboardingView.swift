//
//  OnboardingView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/9/25.
//

import SwiftUI
import SwiftUIIntrospect

struct OnboardingView: View {

	let slides: [Slide] = [Slide(image: .onboardingImage0,
								 title: LocalizableString.Onboarding.forecastForEveryCorner.localized),
						   Slide(image: .onboardingImage1,
								 title: LocalizableString.Onboarding.liveTransparentNetwork.localized),
						   Slide(image: .onboardingImage2,
								 title: LocalizableString.Onboarding.contributeAndEarn.localized),
						   Slide(image: .onboardingImage3,
								 title: LocalizableString.Onboarding.communityPowered.localized),
						   Slide(image: .onboardingImage4,
								 title: LocalizableString.Onboarding.localWeatherData.localized)]

	@Binding var show: Bool
	@StateObject var viewModel: OnboardingViewModel
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
				VStack(spacing: CGFloat(.smallSpacing)) {
					Image(asset: .weatherXMLogoText)

					Text(LocalizableString.Onboarding.title.localized)
						.foregroundStyle(Color(colorEnum: .textDarkStable))
						.font(.system(size: CGFloat(.smallTitleFontSize)))
				}

				slidesScroller()

				VStack(spacing: CGFloat(.defaultSpacing)) {
					Button {
						viewModel.handleSignUpButtonTap(show: $show)
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
						show.toggle()
						viewModel.handleExploreAppButtonTap()
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
	func slidesScroller() -> some View {
		GeometryReader { proxy in
			ScrollView(.horizontal) {
				LazyHStack(spacing: 0.05 * proxy.size.width) {
					ForEach(slides) { slide in
						cardView(slide: slide,
								 size: proxy.size)
						.frame(width: 0.8 * proxy.size.width)
						.id(slide.id)
					}
				}
				.padding(.horizontal, 0.1 * proxy.size.width)
				.modify { view in
					if #available(iOS 17.0, *) {
						view.scrollTargetLayout()
					} else {
						view
							.background {
								GeometryReader { localProxy in
									let _ = updateCurrentSlideId(containerWidth: proxy.size.width,
																 offset: -localProxy.frame(in: .named("scroller")).origin.x)
									Color.clear
								}
							}
					}
				}
			}
			.disableScrollClip()
			.modify { view in
				if #available(iOS 17.0, *) {
					view
						.scrollTargetBehavior(.viewAligned)
						.scrollPosition(id: $currentSlideId)
				} else {
					view
						.coordinateSpace(name: "scroller")
				}
			}
			.scrollIndicators(.hidden)
		}
	}

	@ViewBuilder
	func cardView(slide: Slide, size: CGSize) -> some View {
		ZStack {
			Image(asset: slide.image)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: 0.8 * size.width, height: size.height)
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

	func updateCurrentSlideId(containerWidth: CGFloat, offset: CGFloat) {
		let slideWidth = 0.8 * containerWidth
		let spacing = 0.05 * containerWidth
		let itemWidth = slideWidth + spacing
		var index = Int(round(offset / itemWidth))

		DispatchQueue.main.async {
			index = index.clamped(to: 0...slides.count)
			currentSlideId = slides[index].id
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
		OnboardingView(show: .constant(true),
					   viewModel: ViewModelsFactory.getOnboardingViewModel())
	}
}

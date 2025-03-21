//
//  PhotoIntroView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/12/24.
//

import SwiftUI

struct PhotoIntroView: View {
	@StateObject var viewModel: PhotoIntroViewModel
	@Environment(\.dismiss) private var dismiss

    var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			GeometryReader { proxy in
				ScrollView {
					VStack(spacing: CGFloat(.XLSpacing)) {
						titleView
							.padding(.horizontal, CGFloat(.mediumToLargeSidePadding))


						instructionsView
							.padding(.horizontal, CGFloat(.mediumToLargeSidePadding))

						examplesView(containerWidth: proxy.size.width)

						uploadPhotosView
							.padding(.horizontal, CGFloat(.mediumToLargeSidePadding))

						termsView
							.padding(.horizontal, CGFloat(.mediumToLargeSidePadding))

					}
					.padding(.top, -proxy.safeAreaInsets.top)
					.padding(.bottom, CGFloat(.mediumToLargeSidePadding))
					.overlay {
						VStack {
							HStack {
								Button {
									dismiss()
								} label: {
									Text(viewModel.closeButtonIcon.rawValue)
										.font(.fontAwesome(font: .FAPro, size: CGFloat(.mediumFontSize)))
										.foregroundColor(Color(colorEnum: .textDarkStable))
										.padding(CGFloat(.smallSidePadding))
										.background {
											Circle().foregroundStyle(Color.black.opacity(0.4))
										}
								}

								Spacer()
							}
							Spacer()
						}
						.padding(.top, CGFloat(.smallSidePadding))
						.padding(.leading, CGFloat(.defaultSidePadding))
					}
				}
				.scrollIndicators(.hidden)
			}
			.iPadMaxWidth()
		}
		.navigationBarHidden(true)
		.onAppear {
			viewModel.handleOnAppear()
		}
    }
}

extension PhotoIntroView {
	struct Instruction: Identifiable {
		var id: AssetEnum {
			icon
		}

		let icon: AssetEnum
		let text: String
		let bullets: [String]
	}
}

private extension PhotoIntroView {
	@ViewBuilder
	var titleView: some View {
		VStack(spacing: CGFloat(.smallToMediumSpacing)) {
			Spacer()

			VStack(spacing: 0.0) {
				Text(LocalizableString.PhotoVerification.allAbout.localized.uppercased())
					.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .darkGrey))

				Text(LocalizableString.PhotoVerification.photoVerificationIntroTitle.localized)
					.font(.system(size: CGFloat(.largeTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

			}

			Text(LocalizableString.PhotoVerification.boostNetworkDescription.localized)
				.font(.system(size: CGFloat(.normalFontSize)))
				.foregroundStyle(Color(colorEnum: .text))
				.multilineTextAlignment(.center)
		}
		.aspectRatio(0.8, contentMode: .fit)
		.background {
			Image(asset: .photoVerificationCover)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.overlay {
					LinearGradient(gradient: Gradient(colors: [Color(colorEnum: .bg),
															   Color(colorEnum: .bg).opacity(0.0)]),
								   startPoint: UnitPoint(x: 0.5, y: 0.78),
								   endPoint: UnitPoint(x: 0.5, y: 0.1))

				}
		}
	}

	@ViewBuilder
	var instructionsView: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			HStack {
				Text(LocalizableString.PhotoVerification.howToTakePhoto.localized)
					.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			ForEach(viewModel.instructions) { instruction in
				instrutionView(instruction)
			}
		}
	}

	@ViewBuilder
	func instrutionView(_ instruction: Instruction) -> some View {
		HStack(alignment: .top, spacing: CGFloat(.mediumSpacing)) {
			Image(asset: instruction.icon)
				.renderingMode(.template)
				.foregroundStyle(Color(colorEnum: .wxmPrimary))
				.frame(width: 30.0, height: 30.0)

			VStack(spacing: 2) {
				HStack {
					Text(instruction.text)
						.font(.system(size: CGFloat(.normalFontSize)))
						.foregroundStyle(Color(colorEnum: .text))

					Spacer()
				}

				ForEach(instruction.bullets, id: \.self) { bullet in
					HStack(alignment: .top, spacing: 2.0) {
						Text(verbatim: "•")
						Text(bullet)
						Spacer()
					}
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .text))
				}

			}

			Spacer()
		}
	}

	@ViewBuilder
	func examplesView(containerWidth: CGFloat) -> some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			HStack {
				Text(LocalizableString.PhotoVerification.photoExamples.localized)
					.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}
			.padding(.horizontal, CGFloat(.mediumToLargeSidePadding))

			let recommendedExamples = viewModel.recommendedExamples
			PhotoIntroExamplesView(containerWidth: containerWidth,
								   title: recommendedExamples.title,
								   examples: recommendedExamples.examples)

			let faultyExamples = viewModel.faultExamples
			PhotoIntroExamplesView(isDestructive: true,
								   containerWidth: containerWidth,
								   title: faultyExamples.title,
								   examples: faultyExamples.examples)
		}
	}

	@ViewBuilder
	var uploadPhotosView: some View {
		VStack(spacing: CGFloat(.defaultSpacing)) {
			HStack {
				Text(LocalizableString.PhotoVerification.uploadPhotos.localized)
					.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}

			HStack {
				Text(LocalizableString.PhotoVerification.uploadPhotosDescription.localized)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .text))

				Spacer()
			}
		}
	}

	@ViewBuilder
	var termsView: some View {
		if viewModel.showTerms {
			VStack(spacing: CGFloat(.defaultSpacing)) {
				HStack(spacing: CGFloat(.smallSpacing)) {
					Toggle("", isOn: $viewModel.areTermsAccepted)
						.labelsHidden()
						.toggleStyle(WXMToggleStyle.Default)
					
					let termsTitle = LocalizableString.PhotoVerification.acceptanceUsePolicy.localized
					let termsLink = DisplayedLinks.acceptanceUsePolicy.linkURL
					let termsText = Text("**[\(termsTitle)](\(termsLink))**".attributedMarkdown!).underline(color: Color(colorEnum: .wxmPrimary))
					Text("\(LocalizableString.Wallet.acceptTermsOfService.localized) \(termsText).")
						.tint(Color(colorEnum: .wxmPrimary))
						.foregroundColor(Color(colorEnum: .text))
						.font(.system(size: CGFloat(.normalFontSize)))
					
					Spacer()
				}
				
				Button {					
					viewModel.handleBeginButtonTap(dismiss: dismiss)
				} label: {
					Text(LocalizableString.PhotoVerification.letsTakeTheFirstPhoto.localized)
				}
				.buttonStyle(WXMButtonStyle(textColor: .top,
											fillColor: .wxmPrimary))
				.disabled(!viewModel.areTermsAccepted)
			}
		}
	}
}

#Preview {
	PhotoIntroView(viewModel: ViewModelsFactory.getPhotoIntroViewModel(deviceId: "", images: []))
}

#Preview {
	PhotoIntroView(viewModel: ViewModelsFactory.getPhotoInstructionsViewModel(deviceId: ""))
}

//
//  PhotoIntroInstructionsView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/7/25.
//

import SwiftUI

struct PhotoIntroInstructionsView: View {
	@ObservedObject var viewModel: PhotoIntroViewModel
	let containerWidth: CGFloat
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		VStack(spacing: CGFloat(.XLSpacing)) {
			instructionsView
				.padding(.horizontal, CGFloat(.mediumToLargeSidePadding))

			examplesView(containerWidth: containerWidth)

			uploadPhotosView
				.padding(.horizontal, CGFloat(.mediumToLargeSidePadding))

			termsView
				.padding(.horizontal, CGFloat(.mediumToLargeSidePadding))
		}
	}
}

extension PhotoIntroInstructionsView {
	struct Instruction: Identifiable {
		var id: AssetEnum {
			icon
		}

		let icon: AssetEnum
		let text: String
		let bullets: [String]
	}
}

private extension PhotoIntroInstructionsView {
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
	GeometryReader { proxy in
		PhotoIntroInstructionsView(viewModel: ViewModelsFactory.getPhotoIntroViewModel(deviceId: "", images: []),
								   containerWidth: proxy.size.width)
	}
}

//
//  PhotoIntroView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/12/24.
//

import SwiftUI

struct PhotoIntroView: View {
	@StateObject var viewModel: PhotoIntroViewModel

    var body: some View {
		GeometryReader { proxy in
			ScrollView {
				VStack(spacing: CGFloat(.XLSpacing)) {
					titleView

					instructionsView

					examplesView(containerWidth: proxy.size.width)

					uploadPhotosView
				}
				.padding(CGFloat(.mediumToLargeSidePadding))
			}
			.scrollIndicators(.hidden)
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
	}
}

private extension PhotoIntroView {
	@ViewBuilder
	var titleView: some View {
		VStack(spacing: CGFloat(.smallToMediumSpacing)) {
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

			Text(instruction.text)
				.font(.system(size: CGFloat(.normalFontSize)))
				.foregroundStyle(Color(colorEnum: .text))

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
}

#Preview {
	PhotoIntroView(viewModel: ViewModelsFactory.getPhotoIntroViewModel())
}

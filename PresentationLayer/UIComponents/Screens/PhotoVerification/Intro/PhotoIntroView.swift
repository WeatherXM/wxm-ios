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

						PhotoIntroInstructionsView(viewModel: viewModel,
												   containerWidth: proxy.size.width)
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
}

#Preview {
	PhotoIntroView(viewModel: ViewModelsFactory.getPhotoIntroViewModel(deviceId: "", images: []))
}

#Preview {
	PhotoIntroView(viewModel: ViewModelsFactory.getPhotoInstructionsViewModel())
}

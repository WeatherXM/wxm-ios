//
//  ClaimDevicePhotoIntroView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/7/25.
//

import SwiftUI

struct ClaimDevicePhotoIntroView: View {
	@StateObject var viewModel: ClaimDevicePhotoIntroViewModel

	var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			GeometryReader { proxy in
				ScrollView {
					VStack (spacing: CGFloat(.largeSpacing)) {
						VStack(spacing: CGFloat(.smallSpacing)) {
							HStack {
								Text(LocalizableString.ClaimDevice.photoVerificationTitle.localized)
									.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
									.foregroundStyle(Color(colorEnum: .darkestBlue))

								Spacer()
							}

							HStack {
								Text(LocalizableString.ClaimDevice.photoVerificationText.localized)
									.font(.system(size: CGFloat(.normalFontSize)))
									.foregroundStyle(Color(colorEnum: .darkGrey))

								Spacer()
							}
						}
						.padding(.horizontal, CGFloat(.defaultSidePadding))

						PhotoIntroInstructionsView(viewModel: viewModel,
												   containerWidth: proxy.size.width)
					}
					.padding(.top, CGFloat(.mediumSidePadding))
				}
				.scrollIndicators(.hidden)
			}
		}
	}
}

#Preview {
	ClaimDevicePhotoIntroView(viewModel: ViewModelsFactory.getClaimDevicePhotoViewModel(completion: {}))
}

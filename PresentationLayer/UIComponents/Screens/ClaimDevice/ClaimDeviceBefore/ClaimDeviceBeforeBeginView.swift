//
//  ClaimDeviceBeforeBeginView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/7/25.
//

import SwiftUI

struct ClaimDeviceBeforeBeginView: View {
	@StateObject var viewModel: ClaimDeviceBeforeBeginViewModel
	var body: some View {
		ZStack {
			Color(colorEnum: .topBG)
				.ignoresSafeArea()
			VStack {
				ScrollView(showsIndicators: false) {
					VStack(spacing: CGFloat(.largeSpacing)) {
						HStack {
							Text(LocalizableString.ClaimDevice.beforeBeginTitle.localized)
								.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .darkestBlue))

							Spacer()
						}

						HStack {
							Text(LocalizableString.ClaimDevice.beforeBeginDescription.localized)
								.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .darkGrey))

							Spacer()
						}

						bulletsView(bullets: viewModel.fistSectionBullets)

						HStack {
							Text(LocalizableString.ClaimDevice.beforeBeginNextUp.localized)
								.font(.system(size: CGFloat(.normalFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .darkGrey))

							Spacer()
						}

						bulletsView(bullets: viewModel.secondSectionBullets)
					}
					.padding(.horizontal, CGFloat(.mediumSidePadding))
					.padding(.top, CGFloat(.mediumSidePadding))
				}

				Button {
					viewModel.handleButtonTap()
				} label: {
					Text(LocalizableString.ClaimDevice.beginStationClaiming.localized)
				}
				.buttonStyle(WXMButtonStyle.filled())
				.padding(.horizontal, CGFloat(.mediumSidePadding))
				.padding(.bottom, CGFloat(.mediumSidePadding))
			}
		}
	}
}

private extension ClaimDeviceBeforeBeginView {
	@ViewBuilder
	func bulletsView(bullets: [ClaimDeviceBulletView.Bullet]) -> some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			ForEach(0..<bullets.count, id: \.self) { index in
				let bullet = bullets[index]
				ClaimDeviceBulletView(bullet: bullet)
			}
		}
	}
}

#Preview {
	ClaimDeviceBeforeBeginView(viewModel: ViewModelsFactory.getClaimBeforeBeginViewModel(completion: {}))
}

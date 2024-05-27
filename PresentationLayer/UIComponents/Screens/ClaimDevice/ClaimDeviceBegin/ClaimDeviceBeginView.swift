//
//  ClaimDeviceBeginView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 30/4/24.
//

import SwiftUI

struct ClaimDeviceBeginView: View {
	@StateObject var viewModel: ClaimDeviceBeginViewModel

    var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()
			VStack {
				ScrollView(showsIndicators: false) {
					VStack(spacing: CGFloat(.largeSpacing)) {
						HStack {
							Text(LocalizableString.ClaimDevice.connectGatewayTitle.localized)
								.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .darkestBlue))

							Spacer()
						}

						bullets

						if let videoLink = viewModel.videoLink {
							HStack {
								Text(LocalizableString.ClaimDevice.connectionText.localized)
									.foregroundStyle(Color(colorEnum: .newText))
									.font(.system(size: CGFloat(.normalFontSize)))

								Spacer()
							}

							Button {
								guard let url = URL(string: videoLink), UIApplication.shared.canOpenURL(url) else {
									return
								}

								UIApplication.shared.open(url)
							} label: {
								Image(asset: .m5Video)
									.resizable()
									.aspectRatio(contentMode: .fit)
							}
						}
					}
					.padding(.horizontal, CGFloat(.mediumSidePadding))
					.padding(.top, CGFloat(.largeSidePadding))
				}
				.clipped()

				Button {
					viewModel.handleButtonTap()
				} label: {
					Text(LocalizableString.ClaimDevice.beginStationClaiming.localized)
				}
				.buttonStyle(WXMButtonStyle.filled())
				.padding(.horizontal, CGFloat(.mediumSidePadding))
			}
		}
    }
}

private extension ClaimDeviceBeginView {
	@ViewBuilder
	var bullets: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			ForEach(0..<viewModel.bullets.count, id: \.self) { index in
				let bullet = viewModel.bullets[index]
				ClaimDeviceBulletView(bullet: bullet)
			}
		}
	}
}

#Preview {
	ClaimDeviceBeginView(viewModel: ClaimDeviceBeginViewModel(completion: {}))
}

//
//  ClaimDeviceSerialNumberView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import SwiftUI

struct ClaimDeviceSerialNumberView: View {
	@StateObject var viewModel: ClaimDeviceSerialNumberViewModel
	let gifFileName = "image_station_qr"

    var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()
			VStack {
				ScrollView(showsIndicators: false) {
					VStack(spacing: CGFloat(.largeSpacing)) {
						HStack {
							Text(LocalizableString.ClaimDevice.prepareGatewayTitle.localized)
								.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .darkestBlue))

							Spacer()
						}

						bullets

						GifImageView(fileName: gifFileName)
							.aspectRatio(1.0, contentMode: .fit)

						if let caption = viewModel.caption {
							Text(caption)
								.foregroundStyle(Color(colorEnum: .text))
								.font(.system(size: CGFloat(.normalFontSize)))
						}
					}
					.padding(.horizontal, CGFloat(.mediumSidePadding))
					.padding(.top, CGFloat(.largeSidePadding))
				}
				.clipped()

				Button {

				} label: {
					Text(LocalizableString.ClaimDevice.beginStationClaiming.localized)
				}
				.buttonStyle(WXMButtonStyle.filled())
				.padding(.horizontal, CGFloat(.mediumSidePadding))
			}
		}
    }
}

private extension ClaimDeviceSerialNumberView {
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
	ClaimDeviceSerialNumberView(viewModel: ClaimDeviceSerialNumberM5ViewModel())
}

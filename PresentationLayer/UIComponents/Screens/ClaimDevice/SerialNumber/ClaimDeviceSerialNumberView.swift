//
//  ClaimDeviceSerialNumberView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import SwiftUI

struct ClaimDeviceSerialNumberView: View {
	let gifFileName = "image_station_qr"

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

//						bullets

						GifImageView(fileName: gifFileName)
							.aspectRatio(1.0, contentMode: .fit)
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

#Preview {
    ClaimDeviceSerialNumberView()
}

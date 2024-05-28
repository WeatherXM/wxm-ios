//
//  ResetDeviceView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/5/24.
//

import SwiftUI

struct ResetDeviceView: View {
	@StateObject var viewModel: ResetDeviceViewModel

    var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			VStack {
				ScrollView(showsIndicators: false) {
					VStack(spacing: CGFloat(.largeSpacing)) {

						HStack {
							Text(LocalizableString.ClaimDevice.resetStationTitle.localized)
								.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
								.foregroundStyle(Color(colorEnum: .darkestBlue))

							Spacer()
						}

						bullets
						
						Image(asset: .stationResetSchematic)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(maxWidth: 600.0)
							.padding(.horizontal)

					}
					.padding(.horizontal, CGFloat(.mediumSidePadding))
					.padding(.top, CGFloat(.largeSidePadding))
				}.clipped()

				Button {
					viewModel.handleButtonTap()
				} label: {
					Text(LocalizableString.ClaimDevice.iVeResetMyDeviceButton.localized)
				}
				.buttonStyle(WXMButtonStyle.filled())
				.padding(.horizontal, CGFloat(.mediumSidePadding))
			}
		}
    }
}

private extension ResetDeviceView {
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
	ResetDeviceView(viewModel: .init() {})
}

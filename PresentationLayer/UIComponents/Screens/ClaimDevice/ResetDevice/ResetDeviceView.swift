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

				VStack(spacing: CGFloat(.defaultSpacing)) {
					resetToggle

					Button {
						viewModel.handleButtonTap()
					} label: {
						Text(LocalizableString.ClaimDevice.pairStationViaBluetooth.localized)
					}
					.buttonStyle(WXMButtonStyle.filled())
					.disabled(!viewModel.resetToggle)
				}
				.padding(.horizontal, CGFloat(.mediumSidePadding))
				.padding(.bottom, CGFloat(.mediumSidePadding))
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

	@ViewBuilder
	var resetToggle: some View {
		HStack(alignment: .center, spacing: CGFloat(.smallSpacing)) {
			Toggle(LocalizableString.ClaimDevice.iVeResetMyDeviceButton.localized,
				   isOn: $viewModel.resetToggle)
			.labelsHidden()
			.toggleStyle(WXMToggleStyle.Default)

			Text(LocalizableString.ClaimDevice.iVeResetMyDeviceButton.localized)
				.foregroundColor(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.normalFontSize)))
				.fixedSize(horizontal: false, vertical: true)

			Spacer()
		}
	}
}

#Preview {
	ResetDeviceView(viewModel: .init() {})
}

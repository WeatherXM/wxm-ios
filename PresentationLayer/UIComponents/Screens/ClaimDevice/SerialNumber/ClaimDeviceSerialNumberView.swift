//
//  ClaimDeviceSerialNumberView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import SwiftUI

struct ClaimDeviceSerialNumberView: View {
	@StateObject var viewModel: ClaimDeviceSerialNumberViewModel

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

						if let gifFileName = viewModel.gifFileName {
							GifImageView(fileName: gifFileName)
								.aspectRatio(1.0, contentMode: .fit)
						}

						if let image = viewModel.image {
							Image(asset: image)
								.resizable()
								.aspectRatio(contentMode: .fit)
						}

						if let caption = viewModel.caption {
							Text(caption)
								.foregroundStyle(Color(colorEnum: .text))
								.font(.system(size: CGFloat(.normalFontSize)))
						}
					}
					.padding(.horizontal, CGFloat(.mediumSidePadding))
					.padding(.top, CGFloat(.mediumSidePadding))
				}

				bottomButtons
					.padding(.horizontal, CGFloat(.mediumSidePadding))
			}
			.padding(.bottom, CGFloat(.mediumSidePadding))
		}
		.sheet(isPresented: $viewModel.showQrScanner) {
			ScannerView(mode: viewModel.scanType, completion: viewModel.handleQRScanResult)
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

	@ViewBuilder
	var bottomButtons: some View {
		HStack(spacing: CGFloat(.mediumSpacing)) {
			Button {
				viewModel.handleSNButtonTap()
			} label: {
				Text(LocalizableString.ClaimDevice.enterSerialNumberManually.localized)
			}
			.buttonStyle(WXMButtonStyle.solid)

			Button {
				viewModel.handleQRCodeButtonTap()
			} label: {
				HStack {
					Text(viewModel.scanButton.icon.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))

					Text(viewModel.scanButton.text)
				}
			}
			.buttonStyle(WXMButtonStyle.filled())
		}
	}
}

#Preview {
	ClaimDeviceSerialNumberView(viewModel: ClaimDeviceSerialNumberPulseViewModel { _ in })
}

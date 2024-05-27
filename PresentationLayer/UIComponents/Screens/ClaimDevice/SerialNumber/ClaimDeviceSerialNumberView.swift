//
//  ClaimDeviceSerialNumberView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/5/24.
//

import SwiftUI
import CodeScanner

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

						GifImageView(fileName: viewModel.gifFileName)
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

				bottomButtons
					.padding(.horizontal, CGFloat(.mediumSidePadding))
			}
		}
		.sheet(isPresented: $viewModel.showQrScanner) {
			CodeScannerView(codeTypes: [.qr], completion: viewModel.handleQRScanResult)
				.overlay(QrScannerView())
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
					Image(asset: .qrCodeBlue)
						.renderingMode(.template)

					Text(LocalizableString.ClaimDevice.scanQRCode.localized)
				}
			}
			.buttonStyle(WXMButtonStyle.filled())
		}
	}
}

#Preview {
	ClaimDeviceSerialNumberView(viewModel: ClaimDeviceSerialNumberM5ViewModel { _ in })
}

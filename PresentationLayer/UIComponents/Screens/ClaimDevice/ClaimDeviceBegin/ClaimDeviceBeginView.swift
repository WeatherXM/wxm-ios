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
								.font(.system(size: CGFloat(.smallTitleFontSize)))
								.foregroundStyle(Color(colorEnum: .darkestBlue))

							Spacer()
						}

						bullets

						HStack {
							Text(LocalizableString.ClaimDevice.connectionText.localized)
								.foregroundStyle(Color(colorEnum: .text))
								.font(.system(size: CGFloat(.normalFontSize)))

							Spacer()
						}

						Button {
						} label: {
							Image(asset: .m5Video)
								.resizable()
								.aspectRatio(contentMode: .fit)
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

extension ClaimDeviceBeginView {
	struct Bullet {
		let fontIcon: FontIcon
		let text: AttributedString
	}
}

private extension ClaimDeviceBeginView {
	@ViewBuilder
	var bullets: some View {
		VStack(spacing: CGFloat(.mediumSpacing)) {
			ForEach(0..<viewModel.bullets.count, id: \.self) { index in
				let bullet = viewModel.bullets[index]
				HStack(alignment: .top, spacing: CGFloat(.smallSpacing)) {
					Text(bullet.fontIcon.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
						.foregroundColor(Color(colorEnum: .text))

					Text(bullet.text)
						.foregroundStyle(Color(colorEnum: .text))
						.font(.system(size: CGFloat(.normalFontSize)))

					Spacer()
				}
			}
		}
	}
}

#Preview {
	ClaimDeviceBeginView(viewModel: .init(completion: {}))
}

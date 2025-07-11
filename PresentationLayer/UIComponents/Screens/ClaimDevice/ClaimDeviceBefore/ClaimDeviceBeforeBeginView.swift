//
//  ClaimDeviceBeforeBeginView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/7/25.
//

import SwiftUI

struct ClaimDeviceBeforeBeginView: View {
	var body: some View {
		ZStack {
			Color(colorEnum: .topBG)
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
						//
						//						if let videoLink = viewModel.videoLink {
						//							HStack {
						//								Text(LocalizableString.ClaimDevice.connectionText.localized)
						//									.foregroundStyle(Color(colorEnum: .newText))
						//									.font(.system(size: CGFloat(.normalFontSize)))
						//
						//								Spacer()
						//							}
						//
						//							Button {
						//								guard let url = URL(string: videoLink), UIApplication.shared.canOpenURL(url) else {
						//									return
						//								}
						//
						//								UIApplication.shared.open(url)
						//							} label: {
						//								Image(asset: .ytClaimVideo)
						//									.resizable()
						//									.aspectRatio(contentMode: .fit)
						//							}
						//						}
						//					}
						//					.padding(.horizontal, CGFloat(.mediumSidePadding))
						//					.padding(.top, CGFloat(.mediumSidePadding))
					}
					
					Button {
						//					viewModel.handleButtonTap()
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
}

//private extension ClaimDeviceBeginView {
//	@ViewBuilder
//	var bullets: some View {
//		VStack(spacing: CGFloat(.mediumSpacing)) {
//			ForEach(0..<viewModel.bullets.count, id: \.self) { index in
//				let bullet = viewModel.bullets[index]
//				ClaimDeviceBulletView(bullet: bullet)
//			}
//		}
//	}
//}

#Preview {
    ClaimDeviceBeforeBeginView()
}

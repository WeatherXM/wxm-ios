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
			Color(colorEnum: .topBG)
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
						
						Image(asset: viewModel.image)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.padding(.horizontal, CGFloat(.largeSidePadding))

						infoText
					}
					.padding(CGFloat(.mediumSidePadding))
				}

				VStack(spacing: CGFloat(.defaultSpacing)) {
					resetToggle

					Button {
						viewModel.handleButtonTap()
					} label: {
						Text(viewModel.ctaButtonTitle)
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
			Toggle(viewModel.resetToggleText, isOn: $viewModel.resetToggle)
			.labelsHidden()
			.toggleStyle(WXMToggleStyle.Default)

			Text(viewModel.resetToggleText)
				.foregroundColor(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.normalFontSize)))
				.fixedSize(horizontal: false, vertical: true)

			Spacer()
		}
	}

	@ViewBuilder
	var infoText: some View {
		if let info = viewModel.infoText {
			HStack(alignment: .top) {
				Text(FontIcon.infoCircle.rawValue)
					.font(.fontAwesome(font: .FAProLight, size: CGFloat(.mediumFontSize)))
					.foregroundStyle(Color(colorEnum: .darkGrey))

				Text(info)
					.font(.system(size: CGFloat(.normalFontSize)))
					.foregroundStyle(Color(colorEnum: .darkGrey))
				Spacer()
			}
		} else {
			EmptyView()
		}
	}
}

#Preview {
	ResetDeviceView(viewModel: .init() {})
}

#Preview {
	ResetDeviceView(viewModel: ViewModelsFactory.getResetPulseViewModel {})
}

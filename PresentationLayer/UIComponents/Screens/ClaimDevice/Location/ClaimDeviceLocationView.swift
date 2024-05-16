//
//  ClaimDeviceLocationView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 15/5/24.
//

import SwiftUI

struct ClaimDeviceLocationView: View {
	@StateObject var viewModel: ClaimDeviceLocationViewModel

	var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			VStack(spacing: CGFloat(.largeSpacing)) {
				VStack(spacing: CGFloat(.smallSpacing)) {
					HStack {
						Text(LocalizableString.ClaimDevice.stationLocationTitle.localized)
							.font(.system(size: CGFloat(.smallTitleFontSize), weight: .bold))
							.foregroundStyle(Color(colorEnum: .darkestBlue))
						
						Spacer()
					}
					
					HStack {
						Text(LocalizableString.ClaimDevice.stationLocationSubtitle.localized.attributedMarkdown ?? "")
							.foregroundStyle(Color(colorEnum: .text))
							.font(.system(size: CGFloat(.normalFontSize)))
						
						Spacer()
					}
				}

				VStack(spacing: CGFloat(.smallToMediumSpacing)) {

					SelectLocationMapView(viewModel: viewModel.locationViewModel)
						.cornerRadius(CGFloat(.cardCornerRadius))

					VStack(spacing: CGFloat(.smallToMediumSpacing)) {
						acknowledgementView

						Button {
						} label: {
							Text(LocalizableString.ClaimDevice.confirmAndProceed.localized)
						}
						.buttonStyle(WXMButtonStyle.filled())
						.disabled(!viewModel.canProceed)
					}
				}
			}
			.padding(CGFloat(.mediumSidePadding))
		}
    }
}

private extension ClaimDeviceLocationView {
	@ViewBuilder
	var acknowledgementView: some View {
		HStack(alignment: .top, spacing: CGFloat(.smallSpacing)) {
			Toggle(LocalizableString.SelectStationLocation.termsText.localized,
				   isOn: $viewModel.termsAccepted)
			.labelsHidden()
			.toggleStyle(WXMToggleStyle.Default)

			Text(LocalizableString.SelectStationLocation.termsText.localized)
				.foregroundColor(Color(colorEnum: .text))
				.font(.system(size: CGFloat(.normalFontSize)))
				.fixedSize(horizontal: false, vertical: true)
		}
	}
}

#Preview {
	ClaimDeviceLocationView(viewModel: .init())
}

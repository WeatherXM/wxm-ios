//
//  ClaimDeviceSetFrequencyView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 31/5/24.
//

import SwiftUI
import DomainLayer

struct ClaimDeviceSetFrequencyView: View {
	@StateObject var viewModel: ClaimDeviceSetFrequencyViewModel

    var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			VStack {
				SelectFrequencyView(selectedFrequency: $viewModel.selectedFrequency,
									isFrequencyAcknowledged: $viewModel.isFrequencyAcknowledged,
									country: viewModel.selectedLocation?.country,
									didSelectFrequencyFromLocation: viewModel.didSelectFrequencyFromLocation,
									preSelectedFrequency: viewModel.preSelectedFrequency)

				bottomButton
			}
			.padding(.horizontal, CGFloat(.mediumSidePadding))
			.padding(.top, CGFloat(.largeSidePadding))
			.padding(.bottom, CGFloat(.mediumSidePadding))

		}
    }
}

private extension ClaimDeviceSetFrequencyView {
	@ViewBuilder
	var bottomButton: some View {
		Button {
			viewModel.handleClaimButtonTap()
		} label: {
			Text(LocalizableString.ClaimDevice.setAndClaim.localized)
		}
		.buttonStyle(WXMButtonStyle.filled())
		.disabled(!viewModel.isFrequencyAcknowledged)
	}

}

#Preview {
	ClaimDeviceSetFrequencyView(viewModel: ViewModelsFactory.getClaimDeviceSetFrequncyViewModel { _ in })
}

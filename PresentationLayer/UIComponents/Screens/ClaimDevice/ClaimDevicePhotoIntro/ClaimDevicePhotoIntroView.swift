//
//  ClaimDevicePhotoIntroView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 14/7/25.
//

import SwiftUI

struct ClaimDevicePhotoIntroView: View {
	@StateObject var viewModel: ClaimDevicePhotoIntroViewModel

	var body: some View {
		ZStack {
			Color(colorEnum: .bg)
				.ignoresSafeArea()

			GeometryReader { proxy in
				ScrollView {
					PhotoIntroInstructionsView(viewModel: viewModel,
											   containerWidth: proxy.size.width)
					.padding(.top, CGFloat(.mediumSidePadding))
				}
				.scrollIndicators(.hidden)
			}
		}
	}
}

#Preview {
	ClaimDevicePhotoIntroView(viewModel: ViewModelsFactory.getClaimDevicePhotoViewModel(completion: {}))
}

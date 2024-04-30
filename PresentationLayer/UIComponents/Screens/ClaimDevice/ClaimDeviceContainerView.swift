//
//  ClaimDeviceContainerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/4/24.
//

import SwiftUI

struct ClaimDeviceContainerView: View {
	@StateObject var viewModel: ClaimDeviceContainerViewModel
	@EnvironmentObject var navigationObject: NavigationObject

    var body: some View {
		VStack {
			ProgressView(value: CGFloat(viewModel.selectedIndex + 1), total: 4.0)
				.tint(Color(colorEnum: .primary))
				.animation(.easeOut(duration: 0.3), value: viewModel.selectedIndex)

			TabViewWrapper(selection: $viewModel.selectedIndex) {
				ForEach(0..<4, id: \.self) { index in
					Text("\(index)")
						.tag(index)
				}
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
			.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
			.zIndex(0)
			.animation(.easeOut(duration: 0.3), value: viewModel.selectedIndex)
		}
		.padding(.horizontal, CGFloat(.mediumSidePadding))
		.padding(.vertical, CGFloat(.mediumToLargeSidePadding))
		.onAppear {
			navigationObject.title = LocalizableString.ClaimDevice.claimNewDevice.localized
		}
    }
}

#Preview {
	NavigationContainerView {
		ClaimDeviceContainerView(viewModel: .init())
	}
}

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
			ProgressView(value: CGFloat(viewModel.selectedIndex + 1), total: CGFloat(viewModel.steps.count))
				.tint(Color(colorEnum: .primary))
				.padding(.horizontal, CGFloat(.mediumSidePadding))
				.animation(.easeOut(duration: 0.3), value: viewModel.selectedIndex)

			TabViewWrapper(selection: $viewModel.selectedIndex) {
				ForEach(0..<viewModel.steps.count, id: \.self) { index in
					let step = viewModel.steps[index]
					step.contentView
						.tag(index)
				}
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
			.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
			.zIndex(0)
			.animation(.easeOut(duration: 0.3), value: viewModel.selectedIndex)
		}
		.padding(.top, CGFloat(.mediumToLargeSidePadding))
		.onAppear {
			navigationObject.title = LocalizableString.ClaimDevice.claimNewDevice.localized
			navigationObject.shouldDismissAction = { [weak viewModel] in
				guard let viewModel, viewModel.selectedIndex > 0 else {
					return true
				}

				viewModel.selectedIndex -= 1
				return false
			}
		}
    }
}

#Preview {
	NavigationContainerView {
		ClaimDeviceContainerView(viewModel: .init(type: .d1))
	}
}

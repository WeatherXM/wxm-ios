//
//  ClaimDeviceContainerView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 29/4/24.
//

import SwiftUI
import DomainLayer

struct ClaimDeviceContainerView: View {
	@StateObject var viewModel: ClaimDeviceContainerViewModel
	@EnvironmentObject var navigationObject: NavigationObject

	var body: some View {
		ZStack {
			Color(colorEnum: .newBG)
				.ignoresSafeArea()

			VStack {
				ProgressView(value: CGFloat(viewModel.selectedIndex + 1), total: CGFloat(viewModel.steps.count))
					.tint(Color(colorEnum: .primary))
					.padding(.horizontal, CGFloat(.mediumSidePadding))
					.animation(.easeOut(duration: 0.3), value: viewModel.selectedIndex)

				ZStack {
					viewModel.steps[viewModel.selectedIndex].contentView
						.id(viewModel.steps[viewModel.selectedIndex].id)
						.transition(AnyTransition.asymmetric(insertion: .move(edge: viewModel.isMovingNext ? .trailing : .leading),
															 removal: .move(edge: viewModel.isMovingNext ? .leading : .trailing)))
						.animation(.easeOut(duration: 0.3), value: viewModel.selectedIndex)
				}
			}
			.padding(.top, CGFloat(.mediumToLargeSidePadding))
			.iPadMaxWidth()
		}
		.onAppear {
			navigationObject.title = viewModel.navigationTitle
		}
		.fullScreenCover(isPresented: $viewModel.showLoading) {
			ClaimDeviceProgressView(state: $viewModel.loadingState)
		}
    }
}

#Preview {
	NavigationContainerView {
		return ClaimDeviceContainerView(viewModel: ViewModelsFactory.getClaimStationContainerViewModel(type: .m5))
	}
}

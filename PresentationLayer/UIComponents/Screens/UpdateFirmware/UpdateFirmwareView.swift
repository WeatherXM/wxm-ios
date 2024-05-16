//
//  UpdateFirmwareView.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/2/23.
//

import SwiftUI
import Toolkit

struct UpdateFirmwareView: View {
    @StateObject var viewModel: UpdateFirmwareViewModel
    @State var stepsViewSize: CGSize = .zero
    @EnvironmentObject var navigationObject: NavigationObject
	private let mainVM: MainScreenViewModel = .shared

    var body: some View {
        ZStack {
            Color(colorEnum: .top)
                .ignoresSafeArea()
            
            installationView
                .padding(.horizontal, CGFloat(.defaultSidePadding))
                .fail(show: Binding(get: { viewModel.state.isFailed }, set: { _ in }), obj: viewModel.state.stateObject )
                .success(show: Binding(get: { viewModel.state.isSuccess }, set: { _ in }), obj: viewModel.state.stateObject )
                .animation(.easeIn, value: viewModel.state)
        }
        .onAppear {
            navigationObject.shouldDismissAction = { [weak viewModel] in
                viewModel?.navigationBackButtonTapped()
				return true
            }

            navigationObject.title = viewModel.navigationTitle

            viewModel.mainVM = mainVM

            WXMAnalytics.shared.trackScreen(.heliumOTA)
        }
    }
}

struct UpdateFirmwareView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationContainerView {
            UpdateFirmwareView(viewModel: UpdateFirmwareViewModel.mockInstance)
        }
    }
}

struct UpdateFirmwareViewSuccess_Previews: PreviewProvider {
    static var previews: some View {
        NavigationContainerView {
            UpdateFirmwareView(viewModel: UpdateFirmwareViewModel.successMockInstance)
        }
    }
}

struct UpdateFirmwareViewError_Previews: PreviewProvider {
    static var previews: some View {
        NavigationContainerView {
            UpdateFirmwareView(viewModel: UpdateFirmwareViewModel.errorMockInstance)
        }
    }
}

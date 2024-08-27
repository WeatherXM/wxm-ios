//
//  ContentView.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 6/5/22.
//

import Network
import SwiftUI
import DomainLayer

public struct MainScreen: View {
    @StateObject var viewModel: MainScreenViewModel
    @Environment(\.scenePhase) var scenePhase

    public init(swinjectHelper: SwinjectInterface) {
        _viewModel = StateObject(wrappedValue: MainScreenViewModel.shared)
    }

    public var body: some View {
        RouterView {
            mainScreenSwitch
				.fullScreenCover(isPresented: $viewModel.showAppUpdatePrompt) {
					AppUpdateView(show: $viewModel.showAppUpdatePrompt,
								  viewModel: ViewModelsFactory.getAppUpdateViewModel())
				}
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        viewModel.initializeConfigurations()
                    }
                }
                .onChange(of: viewModel.isUserLoggedIn) { _ in
                    viewModel.initializeConfigurations()
                }
        }
        .preferredColorScheme(viewModel.theme.colorScheme)
        .onOpenURL {
            viewModel.deepLinkHandler.handleUrl($0)
        }
		.onNotificationReceive { notificationResponse in
			_ = viewModel.deepLinkHandler.handleNotificationReceive(notificationResponse)
		}
    }

    public var mainScreenSwitch: some View {
        ZStack {
            Color(colorEnum: .bg).edgesIgnoringSafeArea(.all)
            switch viewModel.isUserLoggedIn {
                case false:
                    loggedOutUser.environmentObject(viewModel)
                case true:
                    loggedInUser.environmentObject(viewModel)
            }
        }
    }

    public var loggedOutUser: some View {
        ZStack {
			ExplorerView(viewModel: ViewModelsFactory.getExplorerViewModel())
        }
    }

    @ViewBuilder
    public var loggedInUser: some View {
        LoggedInTabViewContainer(swinjectHelper: viewModel.swinjectHelper)
            .environmentObject(viewModel)
    }
}

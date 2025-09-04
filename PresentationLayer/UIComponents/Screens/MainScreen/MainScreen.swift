//
//  ContentView.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 6/5/22.
//

import Network
import SwiftUI
import DomainLayer
import Toolkit
#if DEBUG
import PulseUI
#endif

public struct MainScreen: View {
    @StateObject var viewModel: MainScreenViewModel
    @Environment(\.scenePhase) var scenePhase

    public init(swinjectHelper: SwinjectInterface) {
        _viewModel = StateObject(wrappedValue: MainScreenViewModel.shared)
    }

    public var body: some View {
        RouterView {
			Group {
				if viewModel.showOnboarding {
					OnboardingView(show: $viewModel.showOnboarding,
								   viewModel: ViewModelsFactory.getOnboardingViewModel())
				} else {
					mainScreenView
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
			}
			.animation(.easeIn, value: viewModel.showOnboarding)
        }
        .preferredColorScheme(viewModel.theme.colorScheme)
        .onOpenURL {
            viewModel.deepLinkHandler.handleUrl($0)
        }
		.onNotificationReceive { notificationResponse in
			_ = viewModel.deepLinkHandler.handleNotificationReceive(notificationResponse)
		}
		.modify { view in
			if isRunningOnMac {
				view
					.onAppear {
						viewModel.initializeConfigurations()
					}
			} else {
				view
			}
		}
		#if DEBUG
		.bottomSheet(show: $viewModel.showHttpMonitor, fitContent: false) {
			NavigationStack {
				ConsoleView()
			}
		}
		#endif
    }

	@ViewBuilder
    var mainScreenView: some View {
        ZStack {
            Color(colorEnum: .bg).edgesIgnoringSafeArea(.all)

			TabViewContainer(swinjectHelper: viewModel.swinjectHelper)
				.environmentObject(viewModel)
        }
    }
}

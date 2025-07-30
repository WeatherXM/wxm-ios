//
//  LoggedInTabViewContainer.swift
//  PresentationLayer
//
//  Created by Hristos Condrea on 28/5/22.
//

import DomainLayer
import SwiftUI
import Toolkit

struct TabViewContainer: View {
	@StateObject var mainViewModel: MainScreenViewModel = .shared
    @StateObject var explorerViewModel: ExplorerViewModel
	@StateObject var profileViewModel: ProfileViewModel
	@StateObject var homeViewModel: WeatherStationsHomeViewModel
	@State var overlayControlsSize: CGSize = .zero

    public init(swinjectHelper: SwinjectInterface) {
		_explorerViewModel = StateObject(wrappedValue: ViewModelsFactory.getExplorerViewModel())
		_profileViewModel = StateObject(wrappedValue: ViewModelsFactory.getProfileViewModel())
		_homeViewModel = StateObject(wrappedValue: ViewModelsFactory.getWeatherStationsHomeViewModel())
    }

    var body: some View {
		VStack(spacing: 0.0) {
            selectedTabView
                .animation(.easeIn(duration: 0.3), value: mainViewModel.selectedTab)

            if !explorerViewModel.isSearchActive {
                tabBar
            }
        }
        .fullScreenCover(isPresented: $mainViewModel.showFirmwareUpdate) {
            NavigationContainerView {
                UpdateFirmwareView(viewModel: UpdateFirmwareViewModel(device: mainViewModel.deviceToUpdate ?? DeviceDetails.emptyDeviceDetails) {
                    mainViewModel.showFirmwareUpdate = false
                    if let device = mainViewModel.deviceToUpdate {
                        Router.shared.navigateTo(.stationDetails(ViewModelsFactory.getStationDetailsViewModel(deviceId: device.id ?? "",
                                                                                                              cellIndex: device.cellIndex,
                                                                                                              cellCenter: device.cellCenter?.toCLLocationCoordinate2D())))
                    }
                } cancelCallback: {
                    mainViewModel.showFirmwareUpdate = false
                })
            }
        }
        .fullScreenCover(isPresented: $mainViewModel.showAnalyticsPrompt) {
            AnalyticsView(show: $mainViewModel.showAnalyticsPrompt,
                          viewModel: ViewModelsFactory.getAnalyticsViewModel())
        }
		.wxmAlert(show: $mainViewModel.showTermsPrompt) {
			WXMAlertView(show: $mainViewModel.showTermsPrompt,
						 configuration: mainViewModel.termsAlertConfiguration, bottomView: { EmptyView() })
		}
    }

	@ViewBuilder
	private var selectedTabView: some View {
		switch mainViewModel.selectedTab {
			case .home:
				ScrollView {
					Text(verbatim: "home")
				}
			case .myStations:
				WeatherStationsHomeView(viewModel: homeViewModel,
										overlayControlsSize: $overlayControlsSize,
										isWalletEmpty: $mainViewModel.isWalletMissing)
			case .explorer:
				ExplorerView(viewModel: explorerViewModel)
					.onAppear {
						WXMAnalytics.shared.trackScreen(.explorer)
						explorerViewModel.showTopOfMapItems = true
					}
			case .profile:
				ProfileView(viewModel: profileViewModel)
					.onAppear {
						WXMAnalytics.shared.trackScreen(.profile)
					}
		}
	}

    private var tabBar: some View {
        VStack(spacing: CGFloat(.defaultSpacing)) {
            VStack(spacing: CGFloat(.defaultSpacing)) {
				TabBarView($mainViewModel.selectedTab, mainViewModel.isWalletMissing)
            }
        }
		.animation(.easeIn, value: explorerViewModel.showTopOfMapItems)
    }
}

#Preview {
	TabViewContainer(swinjectHelper: SwinjectHelper.shared)
}

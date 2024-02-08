//
//  WeatherStationsHomeView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 18/5/22.
//

import DomainLayer
import MapKit
import SwiftUI
import Toolkit

struct WeatherStationsHomeView: View {

    @Binding private var isTabBarShowing: Bool
    @Binding private var tabBarItemsSize: CGSize
    @Binding private var isWalletEmpty: Bool
    @State private var showFilters: Bool = false
    @StateObject private var viewModel: WeatherStationsHomeViewModel

    init(swinjectHelper: SwinjectInterface, isTabBarShowing: Binding<Bool>, tabBarItemsSize: Binding<CGSize>, isWalletEmpty: Binding<Bool>) {
        let container = swinjectHelper.getContainerForSwinject()
		_viewModel = StateObject(wrappedValue: ViewModelsFactory.getWeatherStationsHomeViewModel())
        _isTabBarShowing = isTabBarShowing
        _tabBarItemsSize = tabBarItemsSize
        _isWalletEmpty = isWalletEmpty
    }

    var body: some View {
        NavigationContainerView(showBackButton: false) {
            navigationBarRightView
        } content: {
            ContentView(vieModel: viewModel,
                        isTabBarShowing: $isTabBarShowing,
                        tabBarItemsSize: $tabBarItemsSize,
                        isWalletEmpty: $isWalletEmpty)
            .bottomSheet(show: $showFilters, initialDetentId: .large) {
                FilterView(show: $showFilters, viewModel: ViewModelsFactory.getFilterViewModel())
            }
        }
    }

    @ViewBuilder
    var navigationBarRightView: some View {
        Button {
            showFilters = true
        } label: {
            Text(FontIcon.sliders.rawValue)
                .font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
				.foregroundColor(Color(colorEnum: viewModel.isFiltersActive ? .primary : .text))
                .frame(width: 30.0, height: 30.0)
        }
    }
}

private struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var navigationObject: NavigationObject

    @StateObject private var viewModel: WeatherStationsHomeViewModel
    @Binding private var isTabBarShowing: Bool
    @Binding private var tabBarItemsSize: CGSize
    @Binding private var isWalletEmpty: Bool
	private let mainVM: MainScreenViewModel = .shared

    init(vieModel: WeatherStationsHomeViewModel, isTabBarShowing: Binding<Bool>, tabBarItemsSize: Binding<CGSize>, isWalletEmpty: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: vieModel)
        _isTabBarShowing = isTabBarShowing
        _tabBarItemsSize = tabBarItemsSize
        _isWalletEmpty = isWalletEmpty
    }

    var body: some View {
        VStack(spacing: 0.0) {
            weatherStationsFlow(for: viewModel.devices)
                .onAppear {
                    Logger.shared.trackScreen(.deviceList)
                }
                .zIndex(0)
                .onChange(of: viewModel.isTabBarShowing) { newValue in
                    withAnimation {
                        self.isTabBarShowing = newValue
                    }
                }
        }.onAppear {
            viewModel.mainVM = mainVM
			viewModel.getDevices()
            navigationObject.title = LocalizableString.weatherStationsHomeTitle.localized
        }
    }

    @ViewBuilder
    func weatherStationsFlow(for devices: [DeviceDetails]) -> some View {
        weatherStations(devices: devices)
            .wxmEmptyView(show: Binding(get: { devices.isEmpty }, set: { _ in }), configuration: viewModel.getEmptyViewConfiguration())
            .fail(show: $viewModel.isFailed, obj: viewModel.failObj)
            .spinningLoader(show: $viewModel.shouldShowFullScreenLoader, hideContent: true)
    }

    @ViewBuilder
    func weatherStations(devices: [DeviceDetails]) -> some View {
        TrackableScrollView(showIndicators: false,
                            offsetObject: viewModel.scrollOffsetObject) { completion in
            viewModel.getDevices(refreshMode: true, completion: completion)
        } content: {
            VStack(spacing: CGFloat(.smallSpacing)) {
                if mainVM.showWalletWarning && isWalletEmpty {
                    CardWarningView(title: LocalizableString.walletAddressMissingTitle.localized,
                                    message: LocalizableString.walletAddressMissingText.localized) {

                        Logger.shared.trackEvent(.prompt, parameters: [.promptName: .walletMissing,
                                                                       .promptType: .warnPromptType,
                                                                       .action: .dismissAction])

                        withAnimation {
                            mainVM.hideWalletWarning()
                        }
                    } content: {
                        Button {
                            Router.shared.navigateTo(.wallet(ViewModelsFactory.getMyWalletViewModel()))
                            Logger.shared.trackEvent(.prompt, parameters: [.promptName: .walletMissing,
                                                                           .promptType: .warnPromptType,
                                                                           .action: .action])

                        } label: {
                            Text(LocalizableString.addWalletTitle.localized)
                                .foregroundColor(Color(colorEnum: .primary))
                                .font(.system(size: CGFloat(.smallFontSize), weight: .bold))
                        }
                    }
                    .onAppear {
                        Logger.shared.trackEvent(.prompt, parameters: [.promptName: .walletMissing,
                                                                       .promptType: .warnPromptType,
                                                                       .action: .viewAction])
                    }
                }

                weatherStationsList(devices: devices)
            }
            .padding(.horizontal, CGFloat(.defaultSidePadding))
            .padding(.top)
            .padding(.bottom, tabBarItemsSize.height)
        }
    }

    @ViewBuilder
    func weatherStationsList(devices: [DeviceDetails]) -> some View {
		AdaptiveGridContainerView {
            ForEach(devices) { device in
                WeatherStationCard(device: device, followState: viewModel.getFollowState(for: device)) {
                    mainVM.showFirmwareUpdate(device: device)
                } viewMoreAction: {
                    Router.shared.navigateTo(.viewMoreAlerts(ViewModelsFactory.getAlertsViewModel(device: device,
                                                                                                  mainVM: mainVM,
                                                                                                  followState: viewModel.getFollowState(for: device))))
                } followAction: {
                    viewModel.followButtonTapped(device: device)
                }
                .onTapGesture {
                    Router.shared.navigateTo(.stationDetails(ViewModelsFactory.getStationDetailsViewModel(deviceId: device.id ?? "",
                                                                                                          cellIndex: device.cellIndex,
                                                                                                          cellCenter: device.cellCenter?.toCLLocationCoordinate2D())))
                    Logger.shared.trackEvent(.userAction, parameters: [.actionName: .selectDevice,
                                                                       .contentType: .userDeviceList,
                                                                       .itemListId: .custom(device.id ?? "")])
                }
            }
        }
        .padding(.bottom)
    }
}

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
    @StateObject private var viewModel: WeatherStationsHomeViewModel

    init(swinjectHelper: SwinjectInterface, isTabBarShowing: Binding<Bool>, tabBarItemsSize: Binding<CGSize>, isWalletEmpty: Binding<Bool>) {
		_viewModel = StateObject(wrappedValue: ViewModelsFactory.getWeatherStationsHomeViewModel())
        _isTabBarShowing = isTabBarShowing
        _tabBarItemsSize = tabBarItemsSize
        _isWalletEmpty = isWalletEmpty
    }

    var body: some View {
		NavigationContainerView(showBackButton: false, titleImage: .wxmNavigationLogo) {
            navigationBarRightView
        } content: {
            ContentView(vieModel: viewModel,
                        isTabBarShowing: $isTabBarShowing,
                        tabBarItemsSize: $tabBarItemsSize,
                        isWalletEmpty: $isWalletEmpty)
        }
    }

	@ViewBuilder
	var navigationBarRightView: some View {
		if let totalEarnedTitle = viewModel.totalEarnedTitle {
			Button {

			} label: {
				HStack(spacing: CGFloat(.mediumSpacing)) {
					VStack(alignment: .leading, spacing: 0.0) {
						if let totalEarnedTitle = viewModel.totalEarnedTitle {
							Text(totalEarnedTitle)
								.font(.system(size: CGFloat(.caption)))
								.foregroundStyle(Color(colorEnum: .text))
						}

						if let totalEarnedValueText = viewModel.totalEarnedValueText {
							Text(totalEarnedValueText)
								.font(.system(size: CGFloat(.normalFontSize), weight: .medium))
								.foregroundStyle(Color(colorEnum: .text))
						}
					}

					Text(FontIcon.chevronRight.rawValue)
						.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.mediumFontSize)))
						.foregroundColor(Color(colorEnum: .midGrey))

				}
				.WXMCardStyle(backgroundColor: Color(colorEnum: .layer1),
							  insideHorizontalPadding: CGFloat(.smallSidePadding),
							  insideVerticalPadding: CGFloat(.smallSidePadding),
							  cornerRadius: CGFloat(.buttonCornerRadius))
			}
			.transition(.opacity.animation(.easeIn))
		}
	}
}

private struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var navigationObject: NavigationObject

	@State private var showFilters: Bool = false
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
                    WXMAnalytics.shared.trackScreen(.deviceList)
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
        }
		.bottomSheet(show: $showFilters, initialDetentId: .large) {
			FilterView(show: $showFilters, viewModel: ViewModelsFactory.getFilterViewModel())
		}
    }

	@ViewBuilder
	var navigationBarRightView: some View {
		Button {
			showFilters = true
		} label: {
			Text(FontIcon.barsFilter.rawValue)
				.font(.fontAwesome(font: .FAProSolid, size: CGFloat(.smallTitleFontSize)))
				.foregroundColor(Color(colorEnum: viewModel.isFiltersActive ? .wxmPrimary : .text))
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
			VStack(spacing: CGFloat(.defaultSpacing)) {
				NavigationTitleView(title: .constant(LocalizableString.weatherStationsHomeTitle.localized),
									subtitle: .constant(nil)) {
					navigationBarRightView
				}

				VStack(spacing: CGFloat(.smallSpacing)) {

					if mainVM.showWalletWarning && isWalletEmpty {
						CardWarningView(title: LocalizableString.walletAddressMissingTitle.localized,
										message: LocalizableString.walletAddressMissingText.localized) {

							WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .walletMissing,
																				 .promptType: .warnPromptType,
																				 .action: .dismissAction])

							withAnimation {
								mainVM.hideWalletWarning()
							}
						} content: {
							Button {
								Router.shared.navigateTo(.wallet(ViewModelsFactory.getMyWalletViewModel()))
								WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .walletMissing,
																					 .promptType: .warnPromptType,
																					 .action: .action])

							} label: {
								Text(LocalizableString.addWalletTitle.localized)
									.foregroundColor(Color(colorEnum: .wxmPrimary))
									.font(.system(size: CGFloat(.smallFontSize), weight: .bold))
							}
						}
						.onAppear {
							WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .walletMissing,
																				 .promptType: .warnPromptType,
																				 .action: .viewAction])
						}
					}

					weatherStationsList(devices: devices)
				}
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
                    WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .selectDevice,
                                                                       .contentType: .userDeviceList,
                                                                       .itemListId: .custom(device.id ?? "")])
                }
            }
        }
        .padding(.bottom)
    }
}

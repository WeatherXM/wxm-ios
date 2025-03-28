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
	@Binding private var overlayControlsSize: CGSize
    @Binding private var isWalletEmpty: Bool
    @StateObject private var viewModel: WeatherStationsHomeViewModel

	init(viewModel: WeatherStationsHomeViewModel,
		 isTabBarShowing: Binding<Bool>,
		 tabBarItemsSize: Binding<CGSize>,
		 overlayControlsSize: Binding<CGSize>,
		 isWalletEmpty: Binding<Bool>) {
		_viewModel = StateObject(wrappedValue: viewModel)
        _isTabBarShowing = isTabBarShowing
        _tabBarItemsSize = tabBarItemsSize
		_overlayControlsSize = overlayControlsSize
        _isWalletEmpty = isWalletEmpty
    }

    var body: some View {
		NavigationContainerView(showBackButton: false, titleImage: .wxmNavigationLogo) {
            navigationBarRightView
        } content: {
            ContentView(vieModel: viewModel,
                        isTabBarShowing: $isTabBarShowing,
                        tabBarItemsSize: $tabBarItemsSize,
						overlayControlsSize: $overlayControlsSize,
                        isWalletEmpty: $isWalletEmpty)
        }
		.onDisappear {
			viewModel.viewWillDisappear()
		}
    }

	@ViewBuilder
	var navigationBarRightView: some View {
		if let stationRewardsTitle = viewModel.stationRewardsTitle {
			Button {
				viewModel.handleRewardAnalyticsTap()
			} label: {
				HStack(spacing: CGFloat(.mediumSpacing)) {
					VStack(alignment: .leading, spacing: 0.0) {
						Text(stationRewardsTitle)
							.font(.system(size: CGFloat(.caption)))
							.foregroundStyle(Color(colorEnum: .text))

						if let stationRewardsValueText = viewModel.stationRewardsValueText {
							Text(stationRewardsValueText)
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
	@Binding private var overlayControlsSize: CGSize
    @Binding private var isWalletEmpty: Bool
	@StateObject var mainVM: MainScreenViewModel = .shared

    init(vieModel: WeatherStationsHomeViewModel,
		 isTabBarShowing: Binding<Bool>,
		 tabBarItemsSize: Binding<CGSize>,
		 overlayControlsSize: Binding<CGSize>,
		 isWalletEmpty: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: vieModel)
        _isTabBarShowing = isTabBarShowing
        _tabBarItemsSize = tabBarItemsSize
		_overlayControlsSize = overlayControlsSize
        _isWalletEmpty = isWalletEmpty
    }

    var body: some View {
        VStack(spacing: 0.0) {
            weatherStationsFlow(for: viewModel.devices)
				.spinningLoader(show: $viewModel.shouldShowFullScreenLoader, hideContent: true)
				.animation(.easeIn, value: viewModel.infoBanner)
				.animation(.easeIn, value: viewModel.uploadState)
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
		.bottomSheet(show: $showFilters, fitContent: false) {
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
	var infoBannerView: some View {
		if let infoBanner = viewModel.infoBanner {
			InfoBannerView(infoBanner: infoBanner) {
				viewModel.handleInfoBannerDismissTap()
			} tapUrlAction: { url in
				viewModel.handleInfoBannerActionTap(url: url)
			}
			.padding(CGFloat(.defaultSidePadding))
			.padding(.bottom, CGFloat(.cardCornerRadius))
			.background(Color(colorEnum: .layer1))
		}
	}

    @ViewBuilder
	func weatherStationsFlow(for devices: [DeviceDetails]) -> some View {
		let infoBannerIsVisible = viewModel.infoBanner != nil

		if viewModel.isFailed, let failObj = viewModel.failObj {
			VStack(spacing: -CGFloat(.cardCornerRadius)) {
				infoBannerView

				FailView(obj: failObj)
					.padding(.horizontal, CGFloat(.defaultSidePadding))

					.background(Color(colorEnum: .bg))
					.clipShape(RoundedRectangle(cornerRadius: infoBannerIsVisible ? CGFloat(.cardCornerRadius) : 0.0))
			}
		} else if devices.isEmpty {
			ZStack {
				Color(colorEnum: .bg)
					.ignoresSafeArea()
				WeatherStationsEmptyView(buyButtonAction: { viewModel.handleBuyButtonTap() },
										 followButtonAction: { viewModel.handleFollowInExplorerTap() })
				.padding(.bottom, overlayControlsSize.height)
			}
		} else {
			weatherStations(devices: devices)
		}
	}

	@ViewBuilder
	func weatherStations(devices: [DeviceDetails]) -> some View {
		let infoBannerIsVisible = viewModel.infoBanner != nil
		TrackableScroller(showIndicators: false,
						  offsetObject: viewModel.scrollOffsetObject) {  completion in
			viewModel.getDevices(refreshMode: true, completion: completion)
		} content: {
			VStack(spacing: -CGFloat(.cardCornerRadius)) {
				infoBannerView
				
				VStack(spacing: CGFloat(.defaultSpacing)) {
					if let uploadState = viewModel.uploadState {
						UploadProgressView(state: uploadState,
										   stationName: viewModel.uploadInProgressStationName ?? "",
										   tapAction: {
							viewModel.handleUploadBannerTap()
						}) {
							withAnimation {
								viewModel.uploadState = nil
							}
						}
					}

					if let announcement = viewModel.announcementConfiguration {
						AnnouncementCardView(configuration: announcement)
					}

					if mainVM.showWalletWarning && isWalletEmpty {
						CardWarningView(configuration: .init(title: LocalizableString.walletAddressMissingTitle.localized,
															 message: LocalizableString.walletAddressMissingText.localized) {

							WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .walletMissing,
																				 .promptType: .warnPromptType,
																				 .action: .dismissAction])

							withAnimation {
								mainVM.hideWalletWarning()
							}
						}) {
							HStack {
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

								Spacer()
							}
						}
						.onAppear {
							WXMAnalytics.shared.trackEvent(.prompt, parameters: [.promptName: .walletMissing,
																				 .promptType: .warnPromptType,
																				 .action: .viewAction])
						}
					}


					NavigationTitleView(title: .constant(LocalizableString.weatherStationsHomeTitle.localized),
										subtitle: .constant(nil)) {
						navigationBarRightView
					}
					
					VStack(spacing: CGFloat(.smallSpacing)) {
						weatherStationsList(devices: devices)
					}
				}
				.padding(.horizontal, CGFloat(.defaultSidePadding))
				.padding(.top)
				.padding(.bottom, tabBarItemsSize.height)
				.background(Color(colorEnum: .bg))
				.clipShape(RoundedRectangle(cornerRadius: infoBannerIsVisible ? CGFloat(.cardCornerRadius) : 0.0))
			}
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

#Preview {
	WeatherStationsHomeView(viewModel: ViewModelsFactory.getWeatherStationsHomeViewModel(),
							isTabBarShowing: .constant(false),
							tabBarItemsSize: .constant(.zero),
							overlayControlsSize: .constant(.zero),
							isWalletEmpty: .constant(false))
}

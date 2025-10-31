//
//  MyStationsView.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 18/5/22.
//

import DomainLayer
import MapKit
import SwiftUI
import Toolkit

struct MyStationsView: View {

	@Binding private var overlayControlsSize: CGSize
    @Binding private var isWalletEmpty: Bool
    @StateObject private var viewModel: MyStationsViewModel

	init(viewModel: MyStationsViewModel,
		 overlayControlsSize: Binding<CGSize>,
		 isWalletEmpty: Binding<Bool>) {
		_viewModel = StateObject(wrappedValue: viewModel)
		_overlayControlsSize = overlayControlsSize
        _isWalletEmpty = isWalletEmpty
    }

    var body: some View {
		NavigationContainerView(showBackButton: false, titleImage: .wxmNavigationLogo) {
            navigationBarRightView
        } content: {
            ContentView(vieModel: viewModel,
						overlayControlsSize: $overlayControlsSize,
                        isWalletEmpty: $isWalletEmpty)
        }
		.onDisappear {
			viewModel.viewWillDisappear()
		}
    }

	@ViewBuilder
	var navigationBarRightView: some View {
		StationRewardsChipView(viewModel: viewModel.stationRewardsChipViewModel)
	}
}

private struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var navigationObject: NavigationObject

	@State private var showFilters: Bool = false
    @StateObject private var viewModel: MyStationsViewModel
	@Binding private var overlayControlsSize: CGSize
    @Binding private var isWalletEmpty: Bool
	@StateObject var mainVM: MainScreenViewModel = .shared

    init(vieModel: MyStationsViewModel,
		 overlayControlsSize: Binding<CGSize>,
		 isWalletEmpty: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: vieModel)
		_overlayControlsSize = overlayControlsSize
        _isWalletEmpty = isWalletEmpty
    }

    var body: some View {
        VStack(spacing: 0.0) {
            weatherStationsFlow(for: viewModel.devices)
				.spinningLoader(show: $viewModel.shouldShowFullScreenLoader, hideContent: true)
				.animation(.easeIn, value: viewModel.uploadState)
                .onAppear {
                    WXMAnalytics.shared.trackScreen(.deviceList)
                }
                .zIndex(0)
        }.onAppear {
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
	func weatherStationsFlow(for devices: [DeviceDetails]) -> some View {
		if viewModel.isFailed, let failObj = viewModel.failObj {
			VStack {
				FailView(obj: failObj)
					.padding(.horizontal, CGFloat(.defaultSidePadding))

					.background(Color(colorEnum: .bg))
			}
			.iPadMaxWidth()
		} else if devices.isEmpty || !viewModel.isLoggedIn {
			ZStack {
				Color(colorEnum: .bg)
					.ignoresSafeArea()
				MyStationsEmptyView(buyButtonAction: { viewModel.handleBuyButtonTap() },
										 followButtonAction: { viewModel.handleFollowInExplorerTap() })
				.padding(.bottom, overlayControlsSize.height)
			}
			.overlay {
				if viewModel.isLoggedIn {
					addStationsButton
				}
			}
			.iPadMaxWidth()
		} else {
			weatherStations(devices: devices)
				.overlay {
					addStationsButton
				}
		}
	}

	@ViewBuilder
	func weatherStations(devices: [DeviceDetails]) -> some View {
		TrackableScroller(showIndicators: false,
						  offsetObject: viewModel.scrollOffsetObject) {  completion in
			viewModel.getDevices(refreshMode: true, completion: completion)
		} content: {
			VStack {
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
				.background(Color(colorEnum: .bg))
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

	@ViewBuilder
	var addStationsButton: some View {
		VStack {
			Spacer()

			HStack {
				Spacer()
				AddButton(showNotification: $viewModel.shouldShowAddButtonBadge)
			}
		}
		.padding(CGFloat(.defaultSidePadding))
		.opacity(viewModel.isAddButtonVisible ? 1.0 : 0.0)
		.animation(.easeIn(duration: 0.2), value: viewModel.isAddButtonVisible)
	}
}

#Preview {
	MyStationsView(viewModel: ViewModelsFactory.getMyStationsViewModel(),
							overlayControlsSize: .constant(.zero),
							isWalletEmpty: .constant(false))
}

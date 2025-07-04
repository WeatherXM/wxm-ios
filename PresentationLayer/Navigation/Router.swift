//
//  Router.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 25/7/23.
//

import Foundation
import SwiftUI
import Toolkit

@MainActor
enum Route: Hashable, Equatable {
	nonisolated static func == (lhs: Route, rhs: Route) -> Bool {
		lhs.hashValue == rhs.hashValue
	}
	
	// swiftlint:disable function_body_length
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(stringRepresentation)
		
		switch self {
			case .stationDetails(let vm):
				hasher.combine(vm)
			case .deviceInfo(let vm):
				hasher.combine(vm)
			case .viewMoreAlerts(let vm):
				hasher.combine(vm)
			case .wallet(let vm):
				hasher.combine(vm)
			case .history(let vm):
				hasher.combine(vm)
			case .netStats(let vm):
				hasher.combine(vm)
			case .transactions(let vm):
				hasher.combine(vm)
			case .settings(let vm):
				hasher.combine(vm)
			case .deleteAccount(let vm):
				hasher.combine(vm)
			case .survey(let userId, let appId):
				hasher.combine("\(userId)-\(appId)")
			case .signIn(let vm):
				hasher.combine(vm)
			case .register(let vm):
				hasher.combine(vm)
			case .resetPassword(let vm):
				hasher.combine(vm)
			case .explorerList(let vm):
				hasher.combine(vm)
			case .rewardDetails(let vm):
				hasher.combine(vm)
			case .webView(let conf):
				hasher.combine("\(conf.title)-\(conf.url)-\(conf.params ?? [:])")
			case .selectStationLocation(let vm):
				hasher.combine(vm)
			case .rewardAnnotations(let vm):
				hasher.combine(vm)
			case .rewardBoosts(let vm):
				hasher.combine(vm)
			case .deleteAccountSuccess(let vm):
				hasher.combine(vm)
			case .forecastDetails(let vm):
				hasher.combine(vm)
			case .claimStationSelection(let vm):
				hasher.combine(vm)
			case .claimStationContainer(let vm):
				hasher.combine(vm)
			case .rewardAnalytics(let vm):
				hasher.combine(vm)
			case .photoIntro(let vm):
				hasher.combine(vm)
			case .photoGallery(let vm):
				hasher.combine(vm)
			case .proPromo(let vm):
				hasher.combine(vm)
			case .tokenMetrics(let vm):
				hasher.combine(vm)
			case .networkGrowth(let vm):
				hasher.combine(vm)
			case .safariView(let url):
				hasher.combine(url)
		}
	}
	// swiftlint:enable function_body_length

	nonisolated
	var stringRepresentation: String {
		switch self {
			case .stationDetails:
				"stationDetails"
			case .deviceInfo:
				"deviceInfo"
			case .viewMoreAlerts:
				"viewMoreAlerts"
			case .wallet:
				"wallet"
			case .history:
				"history"
			case .netStats:
				"netStats"
			case .transactions:
				"transactions"
			case .settings:
				"settings"
			case .deleteAccount:
				"deleteAccount"
			case .survey:
				"survey"
			case .signIn:
				"signIn"
			case .register:
				"register"
			case .resetPassword:
				"resetPassword"
			case .explorerList:
				"explorerList"
			case .rewardDetails:
				"rewardDetails"
			case .webView:
				"webView"
			case .selectStationLocation:
				"selectStationLocation"
			case .rewardAnnotations:
				"rewardAnnotations"
			case .rewardBoosts:
				"rewardBoosts"
			case .deleteAccountSuccess:
				"deleteAccountSuccess"
			case .forecastDetails:
				"forecastDetails"
			case .claimStationSelection:
				"claimStationSelection"
			case .claimStationContainer:
				"claimStationContainer"
			case .rewardAnalytics:
				"rewardAnalytics"
			case .photoIntro:
				"photoIntro"
			case .photoGallery:
				"photoGallery"
			case .proPromo:
				"proPromo"
			case .tokenMetrics:
				"tokenMetrics"
			case .networkGrowth:
				"netWorkGrowth"
			case .safariView:
				"safariView"
		}
	}
	
	case stationDetails(StationDetailsViewModel)
	case deviceInfo(DeviceInfoViewModel)
	case viewMoreAlerts(AlertsViewModel)
	case wallet(MyWalletViewModel)
	case history(HistoryContainerViewModel)
	case netStats(NetworkStatsViewModel)
	case transactions(RewardsTimelineViewModel)
	case settings(SettingsViewModel)
	case deleteAccount(DeleteAccountViewModel)
	case survey(String, String)
	case signIn(SignInViewModel)
	case register(RegisterViewModel)
	case resetPassword(ResetPasswordViewModel)
	case explorerList(ExplorerStationsListViewModel)
	case rewardDetails(RewardDetailsViewModel)
	case webView(WebContainerView.Configuration)
	case selectStationLocation(SelectStationLocationViewModel)
	case rewardAnnotations(RewardAnnotationsViewModel)
	case rewardBoosts(RewardBoostsViewModel)
	case deleteAccountSuccess(DeleteAccountViewModel)
	case forecastDetails(ForecastDetailsViewModel)
	case claimStationSelection(ClaimStationSelectionViewModel)
	case claimStationContainer(ClaimDeviceContainerViewModel)
	case rewardAnalytics(RewardAnalyticsViewModel)
	case photoIntro(PhotoIntroViewModel)
	case photoGallery(GalleryViewModel)
	case proPromo(ProPromotionalViewModel)
	case tokenMetrics(NetworkStatsViewModel)
	case networkGrowth(NetworkStatsViewModel)
	case safariView(URL)
}

extension Route {
	@ViewBuilder
	var view: some View {
		switch self {
			case .stationDetails(let stationDetailsViewModel):
				StationDetailsContainerView(viewModel: stationDetailsViewModel)
			case .deviceInfo(let deviceInfoViewModel):
				NavigationContainerView {
					DeviceInfoView(viewModel: deviceInfoViewModel)
				}
			case .viewMoreAlerts(let viewMoreAlertsViewModel):
				NavigationContainerView {
					MultipleAlertsView(viewModel: viewMoreAlertsViewModel)
				}
			case .wallet(let myWalletViewModel):
				NavigationContainerView {
					MyWalletView(viewModel: myWalletViewModel)
				}
			case .history(let historyViewModel):
				HistoryContainerView(viewModel: historyViewModel)
			case .netStats(let netStatsViewModel):
				NavigationContainerView {
					NetworkStatsView(viewModel: netStatsViewModel)
				}
			case .transactions(let transactionsViewModel):
				NavigationContainerView {
					RewardsTimelineView(viewModel: transactionsViewModel)
				}
			case .settings(let settingsViewModel):
				NavigationContainerView {
					SettingsView(settingsViewModel: settingsViewModel)
				}
			case .deleteAccount(let deleteAccountViewModel):
				NavigationContainerView {
					DeleteAccountView(viewModel: deleteAccountViewModel)
				}
			case .survey(let userId, let appId):
				NavigationContainerView {
					WebView(userID: userId, appID: appId)
				}
			case .signIn(let signInViewModel):
				NavigationContainerView {
					SignInView(viewModel: signInViewModel)
				}
			case .register(let registerViewModel):
				NavigationContainerView {
					RegisterView(viewModel: registerViewModel)
				}
			case .resetPassword(let resetPassViewModel):
				NavigationContainerView {
					ResetPasswordView(viewModel: resetPassViewModel)
				}
			case .explorerList(let explorerListViewModel):
				ExplorerStationsListView(viewModel: explorerListViewModel)
			case .rewardDetails(let rewardDetailsViewModel):
				RewardDetailsView(viewModel: rewardDetailsViewModel)
			case .webView(let conf):
				WebContainerView(configuration: conf)
			case .selectStationLocation(let selectStationLocationViewModel):
				NavigationContainerView {
					SelectStationLocationView(viewModel: selectStationLocationViewModel)
				}
			case .rewardAnnotations(let rewardAnnotationsViewModel):
				RewardAnnotaionsView(viewModel: rewardAnnotationsViewModel)
			case .rewardBoosts(let rewardBoostsViewModel):
				NavigationContainerView {
					RewardBoostsView(viewModel: rewardBoostsViewModel)
				}
			case .deleteAccountSuccess(let deleteAccountViewModel):
				SuccessfulDeleteView(viewModel: deleteAccountViewModel)
			case .forecastDetails(let forecastDetailsViewModel):
				NavigationContainerView {
					ForecastDetailsView(viewModel: forecastDetailsViewModel)
				}
			case .claimStationSelection(let claimStationSelectionViewModel):
				NavigationContainerView {
					ClaimStationSelectionView(viewModel: claimStationSelectionViewModel)
				}
			case .claimStationContainer(let claimDeviceContainerViewModel):
				NavigationContainerView {
					ClaimDeviceContainerView(viewModel: claimDeviceContainerViewModel)
				}
			case .rewardAnalytics(let rewardAnalyticsViewModel):
				RewardAnalyticsView(viewModel: rewardAnalyticsViewModel)
			case .photoIntro(let photoIntroViewModel):
				PhotoIntroView(viewModel: photoIntroViewModel)
			case .photoGallery(let galleryViewModel):
				GalleryView(viewModel: galleryViewModel)
			case .proPromo(let promoViewModel):
				ProPromotionalView(viewModel: promoViewModel)
			case .tokenMetrics(let netStatsViewModel):
				NavigationContainerView {
					TokenMetricsView(viewModel: netStatsViewModel)
				}
			case .networkGrowth(let netStatsViewModel):
				NavigationContainerView {
					NetworkGrowthView(viewModel: netStatsViewModel)
				}
			case .safariView(let url):
				SafariView(url: url)
					.ignoresSafeArea()
		}
	}
}

@MainActor
class Router: ObservableObject {
	
	static let shared = Router()
	
	@Published var path: [Route] = []
	/// We use this to add an, almost, invisible ovelray above `NavigationStack` to fix an issue with dragging gestures of sheet/popover and navigation stack
	/// More info https://stackoverflow.com/questions/71714592/sheet-dismiss-gesture-with-swipe-back-gesture-causes-app-to-freeze
	@Published var showDummyOverlay: Bool = false
	@Published var showFullScreen = false {
		didSet {
			if !showFullScreen {
				// Set ref to nil in order to deallocate the corresponding view model
				fullScreenRoute = nil
			}
		}
	}
	var fullScreenRoute: Route?
	@Published var showBottomSheet = false {
		didSet {
			if !showBottomSheet {
				// Set ref to nil in order to deallocate the corresponding view model
				bottomSheetRoute = nil
			}
		}
	}
	var bottomSheetRoute: Route?
	let navigationHost = HostingWrapper()
		
	func showFullScreen(_ route: Route) {
		if #available(iOS 16.0, *) {
			fullScreenRoute = route
			showFullScreen = true
		} else {
			let hostingVC = UIHostingController(rootView: route.view)
			navigationHost.hostingController?.present(hostingVC, animated: true)
		}
	}

	func showBottomSheet(_ route: Route) {
		bottomSheetRoute = route
		showBottomSheet = true
	}

	func navigateTo(_ route: Route) {
		guard path.last != route else {
			return
		}
		
		if #available(iOS 16.0, *) {
			self.path.append(route)
		} else {
			let hostingVC = UIHostingController(rootView: route.view)
			(navigationHost.hostingController as? UINavigationController)?.pushViewController(hostingVC, animated: true)
		}
	}
	
	func popToRoot() {
		if #available(iOS 16.0, *) {
			self.path = .init()
		} else {
			(navigationHost.hostingController as? UINavigationController)?.popToRootViewController(animated: true)
		}
	}
	
	func pop() {
		if #available(iOS 16.0, *) {
			self.path.removeLast()
		} else {
			(navigationHost.hostingController as? UINavigationController)?.popViewController(animated: true)
		}
	}
}

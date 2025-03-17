//
//  StationDetailsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/3/23.
//

import Combine
import DomainLayer
import Foundation
import Toolkit
import CoreLocation

@MainActor
protocol StationDetailsViewModelDelegate: AnyObject {
    func shouldRefresh() async
    func offsetUpdated(diffOffset: CGFloat)
	func didEndScrollerDragging()
    func shouldAskToFollow()
}

@MainActor
protocol StationDetailsViewModelChild: AnyObject {
	nonisolated func refreshWithDevice(_ device: DeviceDetails?, followState: UserDeviceFollowState?, error: NetworkErrorResponse?) async
    func showLoading()
}

@MainActor
class StationDetailsViewModel: ObservableObject {
    private let deviceId: String
    private let cellIndex: String?
    private let cellCenter: CLLocationCoordinate2D?
    private let useCase: DeviceDetailsUseCase?
	private let meUseCase: MeUseCase?
    private(set) lazy var overviewVM = ViewModelsFactory.getStationOverviewViewModel(device: nil, delegate: self)
    private(set) lazy var forecastVM = ViewModelsFactory.getStationForecastViewModel(delegate: self)
    private(set) lazy var rewardsVM = ViewModelsFactory.getStationRewardsViewModel(deviceId: deviceId, delegate: self)
    private(set) var loginAlertConfiguration: WXMAlertConfiguration?

    private var initialHeaderOffset: CGFloat = 0.0
	@Published private(set) var device: DeviceDetails? {
		didSet {
			shareDialogText = device?.explorerUrl
			let subtitle = device?.friendlyName != nil ? device?.name : nil
			navigationTitle = .init(title: device?.displayName, subtitle: subtitle)
		}
	}
	@Published private(set) var navigationTitle: NavigationObject.NavigationTitle?
    @Published private(set) var followState: UserDeviceFollowState?
    @Published var shouldHideHeaderToggle: Bool = false
    @Published var showLoginAlert: Bool = false
	@Published var showShareDialog: Bool = false
	private(set) var shareDialogText: String?
    private(set) var isHeaderHidden: Bool = false
	var issues: StationChipsView.IssuesChip? {
		device?.getIssuesChip(followState: followState)
	}

    private var cancellables: Set<AnyCancellable> = []

    init(deviceId: String, cellIndex: String?, cellCenter: CLLocationCoordinate2D?, swinjectHelper: SwinjectInterface?) {
        self.deviceId = deviceId
        self.cellIndex = cellIndex
        self.cellCenter = cellCenter
        useCase = swinjectHelper?.getContainerForSwinject().resolve(DeviceDetailsUseCase.self)
		meUseCase = swinjectHelper?.getContainerForSwinject().resolve(MeUseCase.self)
        MainScreenViewModel.shared.$isUserLoggedIn.dropFirst().sink { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.showLoadingInChildViews()
                await self?.fetchDevice()
            }
        }.store(in: &cancellables)

		meUseCase?.userDevicesListChangedPublisher.sink { [weak self] object in
			guard let objectId = object.object as? String, deviceId == objectId else {
				return
			}

			Task { @MainActor [weak self] in
				await self?.fetchDevice()
			}
		}.store(in: &cancellables)
    }

	func viewAppeared() {

	}

    func settingsButtonTapped() {
        Router.shared.navigateTo(.deviceInfo(DeviceInfoViewModel(device: device!, followState: followState)))
    }

	func warningTapped() {
		var parameters: [Parameter: ParameterValue] = [.contentName: .stationDetailsChip,
													   .contentType: .warnings]

		if let issues = device?.issues(mainVM: .shared, followState: followState),
		   issues.count == 1,
		   let itemId = issues.first?.analyticsItemId {
			parameters += [.itemId: itemId]
		}

		WXMAnalytics.shared.trackEvent(.selectContent, parameters: parameters)

		navigateToAlerts()
	}

	@MainActor
    func handleShareButtonTap() {
        WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .deviceDetailsShare])

		// Not so smart solution to handle the race condition between 
		// the popover dismissal and the share dialog presentation
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.showShareDialog = true
		}
    }

    func statusButtonTapped() {
        guard MainScreenViewModel.shared.isUserLoggedIn else {
            showLogin()
            return
        }

        switch followState?.state {
            case .owned:
				Toast.shared.show(text: LocalizableString.StationDetails.ownedStationSnackBarMessage.localized.attributedMarkdown ?? "",
								  type: .info)
            case .followed:
                WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .deviceDetailsFollow,
                                                                   .contentType: .unfollow])
                performUnFollow()
            case .none:
                WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .deviceDetailsFollow,
                                                                   .contentType: .follow])
                performFollow()
        }
    }

    func signupButtonTapped() {
        showLoginAlert = false
        Router.shared.navigateTo(.register(ViewModelsFactory.getRegisterViewModel()))
    }

	func trackScreenViewEvent(for index: Int) {
		guard let tab = StationDetailsViewModel.Tab.allCases[safe: index] else {
			return
		}

		WXMAnalytics.shared.trackScreen(tab.analyticsScreen)
	}
}

extension StationDetailsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(deviceId)
    }
}

extension StationDetailsViewModel {
    enum Tab: CaseIterable, CustomStringConvertible {
        case overview
        case forecast
        case rewards

        var description: String {
            switch self {
                case .overview:
                    return LocalizableString.StationDetails.overview.localized
                case .forecast:
                    return LocalizableString.StationDetails.forecast.localized
                case .rewards:
                    return LocalizableString.StationDetails.rewards.localized
            }
        }

		var analyticsScreen: Screen {
			switch self {
				case .overview:
					return .currentWeather
				case .forecast:
					return .forecast
				case .rewards:
					return .rewards
			}
		}
    }
}

private extension StationDetailsViewModel {
    func performFollow() {
        let followAction = { [weak self] in
            guard let self else {
                return
            }
            LoaderView.shared.show()
			Task { @MainActor [weak self] in
                guard let self,
					  let result = try await self.useCase?.followStation(deviceId: self.deviceId) else {
					LoaderView.shared.dismiss()
                    return
                }

				await self.handleFollowResult(result)

				LoaderView.shared.dismiss()
            }
        }

        if device?.isActive == false {
            AlertHelper.showFollowInActiveStationAlert(deviceName: device?.name ?? "", okAction: followAction)
        } else {
            followAction()
        }
    }

    func performUnFollow() {
        let okAction = {
            LoaderView.shared.show()
			Task { @MainActor [weak self] in
                guard let self,
                      let result = try await self.useCase?.unfollowStation(deviceId: self.deviceId) else {
					LoaderView.shared.dismiss()
                    return
                }

				await self.handleFollowResult(result)

				LoaderView.shared.dismiss()
            }
        }

        AlertHelper.showUnFollowStationAlert(deviceName: device?.name ?? "", okAction: okAction)
    }

    func handleFollowResult(_ result: Result<EmptyEntity, NetworkErrorResponse>) async {
        switch result {
            case .success:
                await fetchDevice()
            case .failure(let error):
                let info = error.uiInfo
                DispatchQueue.main.async {
                    Toast.shared.show(text: info.description?.attributedMarkdown ?? "")
                }
        }
    }

    func fetchDevice() async {
        do {
            guard let res = try await useCase?.getDeviceDetailsById(deviceId: deviceId, cellIndex: cellIndex) else {
                return
            }

            switch res {
                case .success(let deviceDetails):
                    let followState = try? await useCase?.getDeviceFollowState(deviceId: deviceId).get()
                    DispatchQueue.main.async { [weak self, deviceDetails, followState] in
                        self?.device = deviceDetails
                        self?.followState = followState
                    }
                    await self.updateChildViewModels(device: deviceDetails, followState: followState, error: nil)
                case .failure(let error):
                    await self.updateChildViewModels(device: nil, followState: nil, error: error)
            }
        } catch {
            print(error)
        }
    }

    func updateChildViewModels(device: DeviceDetails?, followState: UserDeviceFollowState?, error: NetworkErrorResponse?) async {
        let children: [StationDetailsViewModelChild] = [overviewVM, forecastVM, rewardsVM]
		await children.asyncForEach { await $0.refreshWithDevice(device, followState: followState, error: error) }
    }

    func showLoadingInChildViews() {
        let children: [StationDetailsViewModelChild] = [overviewVM, forecastVM, rewardsVM]
        children.forEach { $0.showLoading() }
    }

    func showLogin() {
        let conf = WXMAlertConfiguration(title: LocalizableString.favoritesloginAlertTitle.localized,
                                         text: LocalizableString.favoritesloginAlertText(device?.name ?? "").localized.attributedMarkdown ?? "",
                                         primaryButtons: [.init(title: LocalizableString.signIn.localized,
																action: { Router.shared.navigateTo(.signIn(ViewModelsFactory.getSignInViewModel())) })])
        loginAlertConfiguration = conf
        showLoginAlert = true
    }

	func navigateToAlerts() {
		guard let device else {
			return
		}
		Router.shared.navigateTo(.viewMoreAlerts(.init(device: device, mainVM: .shared, followState: followState)))
	}
}

// MARK: - StationDetailsViewModelDelegate

extension StationDetailsViewModel: StationDetailsViewModelDelegate {
    func shouldRefresh() async {
        await fetchDevice()
    }

    func offsetUpdated(diffOffset: CGFloat) {
        // Disable the expland/collapse functionality in iOS 15 builds because of internal iOS differencies
        guard #available(iOS 16.0, *) else {
            return
        }

        let threshold = 40.0
        DispatchQueue.main.async { [weak self] in
            if diffOffset > threshold {
                self?.isHeaderHidden = true
                self?.shouldHideHeaderToggle.toggle()
                return
            }

            if diffOffset <= 0 {
                self?.isHeaderHidden = false
                self?.shouldHideHeaderToggle.toggle()
            }
        }
    }

	func didEndScrollerDragging() {

	}
	
    func shouldAskToFollow() {
        statusButtonTapped()
    }
}

// MARK: - Mock

extension StationDetailsViewModel {
    private convenience init() {
        self.init(deviceId: "", cellIndex: nil, cellCenter: nil, swinjectHelper: nil)
        var device = DeviceDetails.emptyDeviceDetails
        device.address = "WetherXM HQ"
        device.name = "A nice station"
        device.isActive = true
        device.lastActiveAt = Date().ISO8601Format()
        self.device = device
    }

    static var mockInstance: StationDetailsViewModel {
        StationDetailsViewModel()
    }
}

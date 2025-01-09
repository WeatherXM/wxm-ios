//
//  WeatherStationsHomeViewModel.swift
//  PresentationLayer
//
//  Created by Danae Kikue Dimou on 25/5/22.
//

import Combine
import DomainLayer
import SwiftUI
import Toolkit

@MainActor
public final class WeatherStationsHomeViewModel: ObservableObject {
	private let meUseCase: MeUseCase
	private let photosUseCase: PhotoGalleryUseCase
	private let remoteConfigUseCase: RemoteConfigUseCase
	private let tabBarVisibilityHandler: TabBarVisibilityHandler
	private var cancellableSet: Set<AnyCancellable> = []
	private var filters: FilterValues? {
		didSet {
			updateFilteredDevices()
		}
	}
	private var allDevices: [DeviceDetails] = [] {
		didSet {
			updateFilteredDevices()
		}
	}

	/// Dicitonary with device id as key.
	/// We use dictionany to reduce the access complexity
	private var followStates: [String: UserDeviceFollowState] = [:] {
		didSet {
			updateFilteredDevices()
			updateTotalEarned()
		}
	}

	private var uploadInProgressDeviceId: String?

	var isFiltersActive: Bool {
		FilterValues.default != filters
	}

	@Published var uploadInProgressStationName: String?
	@Published var uploadState: UploadProgressView.UploadState?
	@Published var infoBanner: InfoBanner?
	@Published var totalEarnedTitle: String?
	@Published var totalEarnedValueText: String?
    @Published var shouldShowFullScreenLoader = true
    @Published var devices = [DeviceDetails]()
    @Published var scrollOffsetObject: TrackableScrollOffsetObject
    @Published var isTabBarShowing: Bool = true
    @Published var isFailed = false
    private(set) var failObj: FailSuccessStateObject?
    weak var mainVM: MainScreenViewModel?

	public init(meUseCase: MeUseCase, remoteConfigUseCase: RemoteConfigUseCase, photosGalleryUseCase: PhotoGalleryUseCase) {
        self.meUseCase = meUseCase
		self.remoteConfigUseCase = remoteConfigUseCase
		self.photosUseCase = photosGalleryUseCase
		let scrollOffsetObject: TrackableScrollOffsetObject = .init()
		self.scrollOffsetObject = scrollOffsetObject
		self.tabBarVisibilityHandler = .init(scrollOffsetObject: scrollOffsetObject)
		self.tabBarVisibilityHandler.$isTabBarShowing.assign(to: &$isTabBarShowing)
        observeFilters()
		
		remoteConfigUseCase.infoBannerPublisher.sink { [weak self] infoBanner in
			self?.infoBanner = infoBanner
		}.store(in: &cancellableSet)

		photosUseCase.uploadProgressPublisher.sink { [weak self] progressResult in
			let deviceId = progressResult.0
			self?.updateUploadInProgressDevice(deviceId: deviceId)
			self?.updateProgressUpload()
		}.store(in: &cancellableSet)

		photosUseCase.uploadErrorPublisher.sink { [weak self] deviceId, error in
			self?.updateUploadInProgressDevice(deviceId: deviceId)
			self?.updateProgressUpload()
		}.store(in: &cancellableSet)

		photosUseCase.uploadCompletedPublisher.sink { [weak self] deviceId in
			self?.updateUploadInProgressDevice(deviceId: deviceId)
			self?.uploadState = .completed
		}.store(in: &cancellableSet)

		if let deviceId = photosUseCase.getUploadInProgressDeviceId() {
			updateUploadInProgressDevice(deviceId: deviceId)
			updateProgressUpload()
		}
    }

	func updateProgressUpload() {
		guard let deviceId = uploadInProgressDeviceId else {
			uploadState = nil
			return
		}

		let state = photosUseCase.getUploadState(deviceId: deviceId)
		switch state {
			case .uploading(let progress):
				self.uploadState = .uploading(progress: Float(progress))
			case .failed:
				self.uploadState = .failed
			case nil:
				self.uploadState = nil
		}
	}

    /// Perform request to get all the essentials
    /// - Parameters:
    ///   - refreshMode: Set true if coming from pull to refresh to prevent showing full screen loader
    ///   - completion: Called once the request is finished
    func getDevices(refreshMode: Bool = false, completion: (() -> Void)? = nil) {
        do {
            shouldShowFullScreenLoader = !refreshMode
            try meUseCase.getDevices()
                .sink { [weak self] response in
                    guard let self else {
                        return
                    }

                    self.shouldShowFullScreenLoader = false
                    switch response {
                        case .failure(let error):
                            let info = error.uiInfo
                            let title = info.title
                            var description = info.description
                            if error.backendError?.code == FailAPICodeEnum.deviceNotFound.rawValue {
                                description = LocalizableString.Error.userDeviceNotFound.localized
                            }

                            let obj = FailSuccessStateObject(type: .weatherStations,
                                                             title: title,
                                                             subtitle: description?.attributedMarkdown,
                                                             cancelTitle: nil,
                                                             retryTitle: LocalizableString.retry.localized,
															 actionButtonsAtTheBottom: false,
                                                             contactSupportAction: {
								HelperFunctions().openContactSupport(successFailureEnum: .weatherStations,
																	 email: self.mainVM?.userInfo?.email,
																	 serialNumber: nil)
                            },
                                                             cancelAction: nil,
                                                             retryAction: { [weak self] in
								self?.getDevices()
							})

                            self.failObj = obj
                            self.isFailed = true
                        case .success(let devices):
                            self.allDevices = devices
                            self.refreshFollowStates()
                            self.isFailed = false
                    }

                    completion?()
                }.store(in: &cancellableSet)
        } catch {
            completion?()
        }
    }

    func getFollowState(for device: DeviceDetails) -> UserDeviceFollowState? {
        guard let deviceId = device.id else {
            return nil
        }

        return followStates[deviceId]
    }

    func followButtonTapped(device: DeviceDetails) {
        guard let followState = getFollowState(for: device) else {
            return
        }

        if followState.relation == .followed {
            WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .devicesListFollow,
                                                               .contentType: .unfollow])
            performUnfollow(device: device)
        } else {
            WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .devicesListFollow,
                                                               .contentType: .follow])
            performFollow(device: device)
        }
    }

    func getEmptyViewConfiguration() -> WXMEmptyView.Configuration? {
        let obj = WXMEmptyView.Configuration(animationEnum: .emptyDevices,
											 backgroundColor: .noColor,
                                             title: LocalizableString.Home.totalWeatherStationsEmptyTitle.localized,
                                             description: LocalizableString.Home.totalWeatherStationsEmptyDescription.localized.attributedMarkdown,
                                             buttonTitle: LocalizableString.Home.totalWeatherStationsEmptyButtonTitle.localized) { [weak self] in
            self?.mainVM?.selectedTab = .mapTab
        }
        return obj
    }

	func handleRewardAnalyticsTap() {
		WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .tokensEarnedPress])
		
		let viewModel = ViewModelsFactory.getRewardAnalyticsViewModel(devices: getOwnedDevices())
		Router.shared.navigateTo(.rewardAnalytics(viewModel))
	}

	func handleInfoBannerDismissTap() {
		guard let bannerId = infoBanner?.id else {
			return
		}

		remoteConfigUseCase.updateLastDismissedInfoBannerId(bannerId)
	}

	func handleInfoBannerActionTap(url: String) {
		guard let url = URL(string: url) else {
			return
		}

		Router.shared.showFullScreen(.safariView(url))
	}

	func handleUploadBannerTap() {
		switch uploadState {
			case .uploading, .completed:
				// Navigate to the station
				guard let device = devices.first(where: { $0.id == uploadInProgressDeviceId}),
					  let deviceId = device.id else {
					return
				}

				let viewModel = ViewModelsFactory.getDeviceInfoViewModel(device: device, followState: followStates[deviceId])
				Router.shared.navigateTo(.deviceInfo(viewModel))
			case .failed:
				guard let deviceId = uploadInProgressDeviceId else {
					return
				}

				Task { @MainActor in
					try? await photosUseCase.retryUpload(deviceId: deviceId)
				}
			case nil:
				break
		}
	}

	func viewWillDisappear() {
		guard uploadState == .completed else {
			return
		}

		uploadState = nil
	}
}

private extension WeatherStationsHomeViewModel {
	func updateUploadInProgressDevice(deviceId: String) {
		self.uploadInProgressDeviceId = deviceId
		self.uploadInProgressStationName = devices.first(where: { $0.id == deviceId })?.displayName
	}

    func refreshFollowStates() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let states: [UserDeviceFollowState] = await self.allDevices.asyncCompactMap { device in
                guard let deviceId = device.id else {
                    return nil
                }
                return try? await self.meUseCase.getDeviceFollowState(deviceId: deviceId).get()
            }

            let followStates: [String: UserDeviceFollowState] = [:]
            self.followStates = states.reduce(into: followStates) { $0[$1.deviceId] = $1 }
        }
    }

    func performFollow(device: DeviceDetails) {
        guard let deviceId = device.id else {
            return
        }

        let followAction = { [weak self] in
            guard let self else {
                return
            }
            LoaderView.shared.show()
            Task {

                let result = try await self.meUseCase.followStation(deviceId: deviceId)

                DispatchQueue.main.async {
                    LoaderView.shared.dismiss {
                        self.handleFollowResult(result)
                    }
                }
            }
        }

        if device.isActive == false {
            let title = LocalizableString.followAlertTitle.localized
            let description = LocalizableString.followAlertDescription(device.name).localized
            let okAction: AlertHelper.AlertObject.Action = (LocalizableString.confirm.localized, { _ in followAction() })
            let obj = AlertHelper.AlertObject(title: title,
                                              message: description,
                                              okAction: okAction)
            AlertHelper().showAlert(obj)

        } else {
            followAction()
        }
    }

    func performUnfollow(device: DeviceDetails) {
        guard let deviceId = device.id else {
            return
        }

        let okAction: AlertHelper.AlertObject.Action = (LocalizableString.confirm.localized, { _ in
            LoaderView.shared.show()
            Task { [weak self] in
                guard let self else {
                    return
                }
                let result = try await meUseCase.unfollowStation(deviceId: deviceId)

                DispatchQueue.main.async {
                    LoaderView.shared.dismiss {
                        self.handleFollowResult(result)
                    }
                }
            }
        })

        let title = LocalizableString.unfollowAlertTitle.localized
        let description = LocalizableString.unfollowAlertDescription(device.name).localized
        let obj = AlertHelper.AlertObject(title: title,
                                          message: description,
                                          okAction: okAction)
        AlertHelper().showAlert(obj)
    }

    func handleFollowResult(_ result: Result<EmptyEntity, NetworkErrorResponse>) {
        switch result {
            case .success:
                DispatchQueue.main.async {
                    self.getDevices()
                }
            case .failure(let error):
                let info = error.uiInfo
                DispatchQueue.main.async {
                    Toast.shared.show(text: info.description?.attributedMarkdown ?? "")
                }
        }
    }

    func observeFilters() {
        meUseCase.getFiltersPublisher().sink { [weak self] filters in
            self?.filters = filters
        }.store(in: &cancellableSet)
    }

    func updateFilteredDevices() {
        guard let filters else {
            devices = allDevices
            return
        }

        var filteredDevices = allDevices.sorted(by: sortDevices(filterValues: filters)).filter(filterDevices(filterValues: filters))

        filteredDevices = groupDevices(devices: filteredDevices, filterValues: filters)
        devices = filteredDevices
    }

    func sortDevices(filterValues: FilterValues) -> (DeviceDetails, DeviceDetails) -> Bool {
        {
            switch filterValues.sortBy {
                case .dateAdded:
                    false
                case .name:
                    $0.displayName < $1.displayName
                case .lastActive:
					($0.lastActiveAt?.timestampToDate() ?? .distantPast) > ($1.lastActiveAt?.timestampToDate() ?? .distantPast)
            }
        }
    }

    func filterDevices(filterValues: FilterValues) -> (DeviceDetails) -> Bool {
        { [weak self] in
            switch filterValues.filter {
                case .all:
                    true
                case .ownedOnly:
                    self?.getFollowState(for: $0)?.state == .owned
                case .favoritesOnly:
                    self?.getFollowState(for: $0)?.state == .followed
            }
        }
    }

    func groupDevices(devices: [DeviceDetails], filterValues: FilterValues) -> [DeviceDetails] {
        switch filterValues.groupBy {
            case .noGroup:
                return devices
            case .relationship:
                let dict = Dictionary(grouping: devices, by: { getFollowState(for: $0)?.state })
                return [dict[.owned], dict[.followed], dict[nil]].flatMap { $0 ?? [] }
            case .status:
                let dict = Dictionary(grouping: devices, by: { $0.isActive })
                return [dict[true], dict[false]].flatMap { $0 ?? [] }
        }
    }

	func updateTotalEarned() {
		let owndedDevices = getOwnedDevices()
		let hasOwned = !owndedDevices.isEmpty
		let totalEarned: Double = owndedDevices.reduce(0.0) { $0 + ($1.rewards?.totalRewards ?? 0.0) }
		
		let noRewardsText = LocalizableString.Home.noRewardsYet.localized
		let totalEarnedText = LocalizableString.Profile.totalEarned.localized
		
		self.totalEarnedTitle = (totalEarned == 0 && hasOwned) ? noRewardsText : totalEarnedText
		self.totalEarnedValueText = (totalEarned == 0 && hasOwned) ? nil : "\(totalEarned.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)" 
	}

	func getOwnedDevices() -> [DeviceDetails] {
		let owndedDevices = allDevices.filter { getFollowState(for: $0)?.relation == .owned}
		return owndedDevices
	}
 }

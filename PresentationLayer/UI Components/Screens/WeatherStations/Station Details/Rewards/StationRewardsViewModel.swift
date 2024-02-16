//
//  StationRewardsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/3/23.
//

import Foundation
import Combine
import DomainLayer
import Toolkit

class StationRewardsViewModel: ObservableObject {
    let offsetObject: TrackableScrollOffsetObject = TrackableScrollOffsetObject()
	@Published private(set) var viewState: ViewState = .loading

	@Published private(set) var totalRewards: Double = 0.0
	@Published var selectedIndex: Int = 0 {
		didSet {
			trackSelectContentChange()
		}
	}
	@Published var data: [StationRewardsCardOverview]?
	lazy var cardButtonActions: RewardsOverviewButtonActions = {
		getCardButtonActions()
	}()

	@Published var showInfo: Bool = false
	private(set) var info: RewardsOverviewButtonActions.Info?

    private(set) var device: DeviceDetails?
	private(set) var followState: UserDeviceFollowState?
    private(set) var failObj: FailSuccessStateObject?

	private var response: NetworkDeviceTokensResponse?
    private var useCase: RewardsUseCase?
    private weak var containerDelegate: StationDetailsViewModelDelegate?
    private let deviceId: String
    private var cancellables: Set<AnyCancellable> = []

    init(deviceId: String, containerDelegate: StationDetailsViewModelDelegate? = nil, useCase: RewardsUseCase?) {
        self.deviceId = deviceId
        self.containerDelegate = containerDelegate
        self.useCase = useCase
        observeOffset()
    }

    func refresh(completion: @escaping VoidCallback) {
        Task { @MainActor in
            await containerDelegate?.shouldRefresh()
            completion()
        }
    }

	func handleViewDetailsTap() {
		guard let device, let cardOverview = data?.first else {
			return
		}

		let viewModel = ViewModelsFactory.getRewardDetailsViewModel(device: device,
																	followState: followState,
																	overview: cardOverview)
		Router.shared.navigateTo(.rewardDetails(viewModel))
	}

    func handleDetailedRewardsButtonTap() {
		navigateToTransactions()
    }

    func handleRetryButtonTap() {
        viewState = .loading
        refresh { }
    }

    func trackSelectContentChange() {
		let state = data?[safe: selectedIndex]?.title ?? ""
        Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .rewardsCard,
                                                              .itemId: .custom(deviceId),
                                                              .state: .custom(state)])
    }
}

private extension StationRewardsViewModel {
    func observeOffset() {
        offsetObject.$diffOffset.sink { [weak self] value in
            guard let self = self else {
                return
            }
            self.containerDelegate?.offsetUpdated(diffOffset: value)
        }
        .store(in: &cancellables)
    }
}

extension StationRewardsViewModel: StationDetailsViewModelChild {
    func refreshWithDevice(_ device: DeviceDetails?, followState: UserDeviceFollowState?, error: NetworkErrorResponse?) async {
        self.device = device
		self.followState = followState
		let tuple = await getRewards()
		if let error = tuple.error {
            DispatchQueue.main.async {
                self.showErrorView(error: error)
            }
            return
        }

        DispatchQueue.main.async {
			self.response = tuple.response
			self.updateOverviews(with: tuple.response!)
            self.viewState = .content
        }
    }

    func showLoading() {
        viewState = .loading
    }
}

private extension StationRewardsViewModel {

	func navigateToTransactions() {
		guard let device else {
			return
		}
		Router.shared.navigateTo(.transactions(ViewModelsFactory.getTransactionDetailsViewModel(device: device, followState: followState)))
	}

    func showErrorView(error: NetworkErrorResponse) {
        let obj = error.uiInfo.defaultFailObject(type: .stationRewards) { [weak self] in
            self?.handleRetryButtonTap()
        }

        DispatchQueue.main.async {
            self.failObj = obj
            self.viewState = .fail
        }
    }

	func getCardButtonActions() -> RewardsOverviewButtonActions {
		let actions = RewardsOverviewButtonActions { [weak self] in
			self?.info = RewardsOverviewButtonActions.rewardsScoreInfo
			self?.showInfo = true
			Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .learnMore,
																  .itemId: .rewardsScore])
		} dailyMaxInfoAction: { [weak self] in
			self?.info = RewardsOverviewButtonActions.dailyMaxInfo
			self?.showInfo = true
			Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .learnMore,
																  .itemId: .maxRewards])
		} timelineInfoAction: { [weak self] in
			var offsetString: String?
			if let identifier = self?.device?.timezone,
			   let timezone = TimeZone(identifier: identifier),
			   !timezone.isUTC {
				offsetString = timezone.hoursOffsetString
			}
			self?.info = RewardsOverviewButtonActions.timelineInfo(timezoneOffset: offsetString)
			self?.showInfo = true
			Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .learnMore,
																  .itemId: .timeline])
		} errorButtonAction: { [weak self] in
			self?.trackErrorButtonTap()
			// If the latest is selected, navigate to reward details
			if self?.selectedIndex == 0,
				let cardOverView = self?.data?[safe: 0],
				let device = self?.device {
				let viewModel = ViewModelsFactory.getRewardDetailsViewModel(device: device,
																			followState: self?.followState,
																			overview: cardOverView)
				Router.shared.navigateTo(.rewardDetails(viewModel))
				return
			}
			self?.navigateToTransactions()
		}

		return actions
	}

	func updateOverviews(with rewards: NetworkDeviceTokensResponse) {
		let errorButtonTitle: String = followState?.relation == .owned ? LocalizableString.StationDetails.ownedRewardsErrorButtonTitle.localized : LocalizableString.StationDetails.rewardsErrorButtonTitle.localized
		let latestRewards = rewards.latest
		let latest = latestRewards?.toRewardsCardOverview(title: LocalizableString.StationDetails.rewardsLatestTab.localized, errorButtonTitle: errorButtonTitle)

		let weekly = rewards.weekly
		let week = weekly?.toRewardsCardOverview(title: LocalizableString.StationDetails.rewardsSevenDaysTab.localized, errorButtonTitle: errorButtonTitle)

		let monthly = rewards.monthly
		let month = monthly?.toRewardsCardOverview(title: LocalizableString.StationDetails.rewardsThirtyDaysTab.localized, errorButtonTitle: errorButtonTitle)

		self.data = [latest, week, month].compactMap { $0 }
		self.totalRewards = rewards.totalRewards ?? 0.0
	}

	func getRewards() async -> (response: NetworkDeviceTokensResponse?, error: NetworkErrorResponse?) {
		do {
			guard let result = try await useCase?.getDeviceRewards(deviceId: deviceId) else {
				return (nil, nil)
			}

			switch result {
				case .success(let rewards):
					return (rewards, nil)
				case .failure(let error):
					return (nil, error)
			}
		} catch {
			print(error)
			return (nil, nil)
		}
	}

	func trackErrorButtonTap() {
		let itemId = data?[safe: selectedIndex]?.title ?? ""
		Logger.shared.trackEvent(.userAction, parameters: [.actionName: .identifyProblems,
														   .contentType: .deviceRewards,
														   .itemId: .custom(itemId)])
	}
}

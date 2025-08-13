//
//  StationRewardsChipViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 4/8/25.
//

import Foundation
import Combine
import DomainLayer
import Toolkit

@MainActor
class StationRewardsChipViewModel: ObservableObject {
	@Published var stationRewardsTitle: String?
	@Published var stationRewardsValueText: String?

	private let useCase: MeUseCaseApi
	private var cancellableSet: Set<AnyCancellable> = []
	private var isLoggedIn: Bool = false {
		didSet {
			updateStationRewards()
		}
	}

	init(useCase: MeUseCaseApi) {
		self.useCase = useCase

		useCase.userDevicesListChangedPublisher.sink { [weak self] _ in
			self?.updateStationRewards()
		}.store(in: &cancellableSet)

		MainScreenViewModel.shared.$isUserLoggedIn.sink { [weak self] value in
			self?.isLoggedIn = value
		}.store(in: &cancellableSet)
	}

	func handleRewardAnalyticsTap() {
		WXMAnalytics.shared.trackEvent(.userAction, parameters: [.actionName: .tokensEarnedPress])

		let viewModel = ViewModelsFactory.getRewardAnalyticsViewModel(devices: getOwnedDevices())
		Router.shared.navigateTo(.rewardAnalytics(viewModel))
	}
}

private extension StationRewardsChipViewModel {
	func updateStationRewards() {
		guard isLoggedIn else {
			self.stationRewardsTitle = LocalizableString.MyStations.ownDeployEarn.localized
			self.stationRewardsValueText = nil

			return
		}

		let owndedDevices = getOwnedDevices()
		let hasOwned = !owndedDevices.isEmpty
		let totalEarned: Double = owndedDevices.reduce(0.0) { $0 + ($1.rewards?.totalRewards ?? 0.0) }

		let noRewardsText = LocalizableString.MyStations.noRewardsYet.localized
		let stationRewardsdText = LocalizableString.RewardAnalytics.stationRewards.localized

		self.stationRewardsTitle = (totalEarned == 0 && hasOwned) ? noRewardsText : stationRewardsdText
		self.stationRewardsValueText = (totalEarned == 0 && hasOwned) ? nil : "\(totalEarned.toWXMTokenPrecisionString) \(StringConstants.wxmCurrency)"
	}

	func getOwnedDevices() -> [DeviceDetails] {
		let owndedDevices = useCase.getCachedOwnedDevices()
		return owndedDevices ?? []
	}
}

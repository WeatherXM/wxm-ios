//
//  RewardBoostsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import Foundation
import DomainLayer
import Toolkit
import UIKit

@MainActor
class RewardBoostsViewModel: ObservableObject {
	let boost: BoostCardView.Boost
	private var useCase: RewardsTimelineUseCaseApi
	private let boostReward: NetworkDeviceRewardDetailsResponse.BoostReward
	private let device: DeviceDetails
	private let linkNavigator: LinkNavigation

	@Published var state: ViewState = .loading
	private(set) var failObj: FailSuccessStateObject?
	private(set) var response: NetworkDeviceRewardBoostsResponse?

	init(boost: NetworkDeviceRewardDetailsResponse.BoostReward,
		 device: DeviceDetails,
		 date: Date?,
		 useCase: RewardsTimelineUseCaseApi,
		 linkNavigation: LinkNavigation = LinkNavigationHelper()) {
		self.boost = boost.toBoostViewObject(with: date)
		self.boostReward = boost
		self.device = device
		self.useCase = useCase
		self.linkNavigator = linkNavigation
		refresh {
			
		}
	}

	func refresh(completion: @escaping VoidCallback) {
		Task { @MainActor [weak self] in
			guard let self else {
				return
			}

			let result = await self.fetchRewardBoosts()
			switch result {
				case .success(let response):
					self.response = response
					self.state = .content
					completion()
				case .failure(let error):
					self.state = .fail
					self.failObj = error.uiInfo(title: LocalizableString.RewardDetails.rewardsBoostFailedTitle.localized).defaultFailObject(type: .rewardDetails) {
						self.state = .loading
						self.refresh {}
					}
					completion()
				case nil:
					completion()
			}
		}
	}

	func handleReadMoreTap() {
		guard let docUrl = response?.metadata?.docUrl else {
			return
		}

		linkNavigator.openUrl(docUrl)

		WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .webDocumentation,
															  .itemId: .custom(docUrl)])
	}
}

private extension RewardBoostsViewModel {
	func fetchRewardBoosts() async -> Result<NetworkDeviceRewardBoostsResponse?, NetworkErrorResponse>? {
		guard let deviceId = device.id, let code = boostReward.code?.rawValue else {
			return nil
		}
		return try? await useCase.getRewardBoosts(deviceId: deviceId, code: code)
	}
}

extension RewardBoostsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
		MainActor.assumeIsolated {
			hasher.combine("\(boost.title)-\(boost.reward)-\(String(describing: boost.date))")
		}
	}
}

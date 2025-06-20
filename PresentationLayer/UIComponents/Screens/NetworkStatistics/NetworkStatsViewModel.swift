//
//  NetworkStatsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/6/23.
//

import Foundation
import DomainLayer
import Combine
import DGCharts
import Toolkit
import SwiftUI

@MainActor
class NetworkStatsViewModel: ObservableObject {

    @Published var rewards: NetworkStatsView.Statistics?
	@Published var health: NetworkStatsView.Statistics?
	@Published var growth: NetworkStatsView.Statistics?
    @Published var token: NetworkStatsView.Statistics?
	@Published var totalAllocated: NetworkStatsView.Statistics?
    @Published var stationStats: [NetworkStatsView.StationStatistics]?
    @Published var manufacturerCTA: NetworkStatsView.StatisticsCTA?
    @Published var lastUpdatedText: String?
    @Published var showInfo: Bool = false
    @Published var state: NetworkStatsView.State = .loading
    private(set) var failObj: FailSuccessStateObject?

    private(set) var info: BottomSheetInfo?

    private var isEmpty: Bool {
        rewards == nil &&
        stationStats == nil
    }

	private let useCase: NetworkUseCaseApi?
    private var cancellables: Set<AnyCancellable> = []
	private let linkNavigation: LinkNavigation
	let router: Router

	init(useCase: NetworkUseCaseApi? = nil,
		 linkNavigation: LinkNavigation = LinkNavigationHelper(),
		 router: Router = .shared) {
        self.useCase = useCase
		self.linkNavigation = linkNavigation
		self.router = router
        refresh { }
    }

    func refresh(completion: @escaping VoidCallback) {
        fetchStats(completion: completion)
    }

    func handleBuyStationTap() {
		linkNavigation.openUrl(DisplayedLinks.shopLink.linkURL)
        WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .openShop])
    }

    func handleDetailsActionTap(statistics: NetworkStatsView.StationStatistics, details: NetworkStatsView.StationDetails) {
        if let url = details.url {
			linkNavigation.openUrl(url)
        }

        WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .openStationShop,
                                                              .itemId: statistics.analyticsItemId,
                                                              .itemListId: .custom(details.title)])
    }

    func handleRetryButtonTap() {
        state = .loading
        refresh { }
    }

    func showInfo(title: String?, description: String, analyticsItemId: ParameterValue?) {
		info = .init(title: title, description: description)
        showInfo = true

        if let analyticsItemId {
            WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .learnMore,
                                                                  .itemId: analyticsItemId])
        }
    }
}

extension NetworkStatsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {

    }
}

private extension NetworkStatsViewModel {
    func fetchStats(completion: @escaping VoidCallback) {
        do {
            try useCase?.getNetworkStats().sink { [weak self] response in
                guard let self else {
                    return
                }
                if let error = response.error {
                    let info = error.uiInfo
                    self.failObj = info.defaultFailObject(type: .networkStats, retryAction: self.handleRetryButtonTap)
                    state = .fail
                } else {
                    self.updateStats(from: response.value)
                    self.state = self.isEmpty ? .empty : .content
                }

                completion()
            }
            .store(in: &cancellables)
        } catch {

        }
    }

    func updateStats(from response: NetworkStatsResponse?) {
        self.rewards = getRewardsStatistics(response: response)
		self.health = getHealthStatistics(response: response)
		self.growth = getGrowthStatistics(response: response)
        self.token = getTokenStatistics(response: response)
		self.totalAllocated = getTotalAllocatedRewards(response: response)
        self.stationStats = getStationStats(response: response)
        self.manufacturerCTA = getManufacturerCTA(response: response)

        if let lastUpdated = response?.lastUpdated {
			lastUpdatedText = LocalizableString.lastUpdated(lastUpdated.localizedDateString()).localized
        }
    }
}

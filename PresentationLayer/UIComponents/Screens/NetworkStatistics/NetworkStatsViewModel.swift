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

    @Published var dataDays: NetworkStatsView.Statistics?
    @Published var rewards: NetworkStatsView.Statistics?
    @Published var token: NetworkStatsView.Statistics?
    @Published var stationStats: [NetworkStatsView.StationStatistics]?
    @Published var buyStationCTA: NetworkStatsView.StatisticsCTA?
    @Published var manufacturerCTA: NetworkStatsView.StatisticsCTA?
    @Published var lastUpdatedText: String?
    @Published var showInfo: Bool = false
    @Published var state: NetworkStatsView.State = .loading
    private(set) var failObj: FailSuccessStateObject?

    private(set) var info: BottomSheetInfo?

    private var isEmpty: Bool {
        dataDays == nil &&
        rewards == nil &&
        stationStats == nil
    }

	private let useCase: NetworkUseCaseApi?
    private var cancellables: Set<AnyCancellable> = []
	private let linkNavigation: LinkNavigation

	init(useCase: NetworkUseCaseApi? = nil,
		 linkNavigation: LinkNavigation = LinkNavigationHelper()) {
        self.useCase = useCase
		self.linkNavigation = linkNavigation
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
        self.dataDays = getDataDaysStatistics(response: response)
        self.rewards = getRewardsStatistics(response: response)
        self.token = getTokenStatistics(response: response)
        self.stationStats = getStationStats(response: response)
        self.buyStationCTA = getBuyStationCTA(response: response)
        self.manufacturerCTA = getManufacturerCTA(response: response)

        if let lastUpdated = response?.lastUpdated {
			lastUpdatedText = LocalizableString.lastUpdated(lastUpdated.localizedDateString()).localized
        }
    }
}

// MARK: - Mock

extension NetworkStatsViewModel {
	static var mock: NetworkStatsViewModel {
		let viewModel = NetworkStatsViewModel()
		viewModel.dataDays = NetworkStatsView.Statistics(title: LocalizableString.NetStats.weatherStationDays.localized,
														 description: nil,
														 showExternalLinkIcon: false,
														 externalLinkTapAction: nil,
														 mainText: "90,2K",
														 accessory: .init(fontIcon: .infoCircle) {
			viewModel.showInfo(title: LocalizableString.NetStats.weatherStationDays.localized,
							   description: "This is info",
							   analyticsItemId: .dataDays)
		},
														 dateString: "Yesterday",
														 chartModel: .mock(),
														 xAxisTuple: nil,
														 analyticsItemId: .dataDays)

		let addtional: [NetworkStatsView.AdditionalStats] = [.init(title: "Total supply",
																   value: "100,000,000",
																   accessory: .init(fontIcon: .infoCircle,
																					action: { }),
																   analyticsItemId: nil),
															 .init(title: "Daily Minted", value: "20,020", analyticsItemId: nil)]
		viewModel.rewards = NetworkStatsView.Statistics(title: LocalizableString.NetStats.wxmRewardsTitle.localized,
														description: nil,
														showExternalLinkIcon: false,
														externalLinkTapAction: nil,
														mainText: "90,2K",
														accessory: .init(fontIcon: .infoCircle) {
			viewModel.showInfo(title: LocalizableString.NetStats.wxmRewardsTitle.localized,
							   description: "This is info",
							   analyticsItemId: .allocatedRewards)
		},
														dateString: "Yesterday",
														chartModel: .mock(),
														xAxisTuple: nil,
														additionalStats: addtional,
														analyticsItemId: .allocatedRewards)

		let stationStats = NetworkStatsView.StationStatistics(title: "Total",
															  total: "7,823",
															  details: [.init(title: "WS1000",
																			  value: "5,642",
																			  percentage: 0.2,
																			  color: .crypto,
																			  url: nil),
																		.init(title: "WS2000",
																			  value: "8,642",
																			  percentage: 1.0,
																			  color: .wxmPrimary,
																			  url: nil)],
															  analyticsItemId: .total)

		let stationStats1 = NetworkStatsView.StationStatistics(title: "Claimed",
															   total: "7,823",
															   accessory: .init(fontIcon: .infoCircle) {
			viewModel.showInfo(title: "Claimed",
							   description: "This is info",
							   analyticsItemId: .claimed)
		},
															   details: [.init(title: "WS1000",
																			   value: "5,642",
																			   percentage: 0.2,
																			   color: .crypto,
																			   url: nil),
																		 .init(title: "WS2000",
																			   value: "8,642",
																			   percentage: 0.8,
																			   color: .wxmPrimary,
																			   url: nil)],
															   analyticsItemId: .claimed)

        viewModel.stationStats = [stationStats, stationStats1]

        return viewModel
    }
}

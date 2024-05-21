//
//  NetworkStatsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 9/6/23.
//

import Foundation
import DomainLayer
import Combine
import Charts
import Toolkit
import SwiftUI

class NetworkStatsViewModel: ObservableObject {

    @Published var dataDays: NetworkStatsView.Statistics?
    @Published var rewards: NetworkStatsView.Statistics?
    @Published var token: NetworkStatsView.Statistics?
    @Published var stationStats: [NetworkStatsView.StationStatistics]?
    @Published var buyStationCTA: NetworkStatsView.StatisticsCTA?
    @Published var manufacturerCTA: NetworkStatsView.StatisticsCTA?
    @Published var lastUpdatedText: String?
    @Published var showInfo: Bool = false
	@Published var showMainnet: Bool? = false
	@Published var mainnetMessage: String?
    @Published var state: NetworkStatsView.State = .loading
    private(set) var failObj: FailSuccessStateObject?

    private(set) var info: BottomSheetInfo?

    private var isEmpty: Bool {
        dataDays == nil &&
        rewards == nil &&
        stationStats == nil
    }

    private let useCase: NetworkUseCase?
    private var cancellables: Set<AnyCancellable> = []

    init(useCase: NetworkUseCase? = nil) {
        self.useCase = useCase
		RemoteConfigManager.shared.$isFeatMainnetEnabled.assign(to: &$showMainnet)
		RemoteConfigManager.shared.$featMainnetMessage.assign(to: &$mainnetMessage)

        refresh { }
    }

    func refresh(completion: @escaping VoidCallback) {
        fetchStats(completion: completion)
    }

    func handleBuyStationTap() {
        HelperFunctions().openUrl(DisplayedLinks.shopLink.linkURL)
        Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .openShop])
    }

    func handleDetailsActionTap(statistics: NetworkStatsView.StationStatistics, details: NetworkStatsView.StationDetails) {
        if let url = details.url {
            HelperFunctions().openUrl(url)
        }

        Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .openStationShop,
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
            Logger.shared.trackEvent(.selectContent, parameters: [.contentType: .learnMore,
                                                                  .itemId: analyticsItemId])
        }
    }
}

extension NetworkStatsViewModel: HashableViewModel {
    func hash(into hasher: inout Hasher) {

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
                                                         info: (LocalizableString.NetStats.weatherStationDays.localized, "This is info"),
                                                         dateString: "Yesterday",
                                                         chartModel: .mock(),
                                                         xAxisTuple: nil,
                                                         analyticsItemId: .dataDays)

        let addtional: [NetworkStatsView.AdditionalStats] = [.init(title: "Total supply", value: "100,000,000", info: ("title", "info"), analyticsItemId: nil),
                                                             .init(title: "Daily Minted", value: "20,020", analyticsItemId: nil)]
        viewModel.rewards = NetworkStatsView.Statistics(title: LocalizableString.NetStats.wxmRewardsTitle.localized,
                                                        description: nil,
                                                        showExternalLinkIcon: false,
                                                        externalLinkTapAction: nil,
                                                        mainText: "90,2K",
                                                        info: (LocalizableString.NetStats.wxmRewardsTitle.localized, "This is info"),
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
                                                                              color: .primary,
                                                                              url: nil)],
                                                              analyticsItemId: .total)

        let stationStats1 = NetworkStatsView.StationStatistics(title: "Claimed",
                                                               total: "7,823",
                                                               info: ("Claimed", "This is info"),
                                                               details: [.init(title: "WS1000",
                                                                               value: "5,642",
                                                                               percentage: 0.2,
                                                                               color: .crypto,
                                                                               url: nil),
                                                                         .init(title: "WS2000",
                                                                               value: "8,642",
                                                                               percentage: 0.8,
                                                                               color: .primary,
                                                                               url: nil)],
                                                               analyticsItemId: .claimed)

        viewModel.stationStats = [stationStats, stationStats1]

        return viewModel
    }
}

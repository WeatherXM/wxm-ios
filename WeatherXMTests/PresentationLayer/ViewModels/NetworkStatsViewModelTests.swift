//
//  NetworkStatsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct NetworkStatsViewModelTests {
	let useCase: MockNetworkUseCase
	let viewModel: NetworkStatsViewModel
	let linkNavigation: MockLinkNavigation

	init() {
		self.useCase = .init()
		self.linkNavigation = .init()
		self.viewModel = .init(useCase: useCase, linkNavigation: linkNavigation)
	}

    @Test func buyStation() async throws {
		#expect(linkNavigation.openedUrl == nil)
		viewModel.handleBuyStationTap()
		#expect(linkNavigation.openedUrl == DisplayedLinks.shopLink.linkURL)
    }

	@Test func detailsActionTap() async throws {
		#expect(linkNavigation.openedUrl == nil)
		let stats = NetworkStatsView.StationStatistics(title: "",
													   total: "",
													   details: [],
													   analyticsItemId: .active)
		let details = NetworkStatsView.StationDetails(title: "",
													  value: "",
													  percentage: 10,
													  color: .info,
													  url: "http://link.com")
		viewModel.handleDetailsActionTap(statistics: stats, details: details)
		#expect(linkNavigation.openedUrl == "http://link.com")
	}
}

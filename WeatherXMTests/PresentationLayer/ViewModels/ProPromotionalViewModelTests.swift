//
//  ProPromotionalViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

import Testing
@testable import WeatherXM

@MainActor
struct ProPromotionalViewModelTests {
	let viewModel: ProPromotionalViewModel
	let linkNavigator: MockLinkNavigation

	init() {
		self.linkNavigator = .init()
		self.viewModel = ProPromotionalViewModel(linkNavigation: linkNavigator)
	}

    @Test func openUrl() async throws {
		#expect(linkNavigator.openedUrl == nil)
		viewModel.handleLearnMoreTapped()
		#expect(linkNavigator.openedUrl == DisplayedLinks.weatherXMPro.linkURL)
    }
}

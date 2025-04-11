//
//  AppUpdateViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 4/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@Suite(.serialized)
@MainActor
struct AppUpdateViewModelTests {
	let viewModel: AppUpdateViewModel
	let mainUseCase: MockMainUseCase
	let linkNavigation: MockLinkNavigation

	init() {
		mainUseCase = .init()
		linkNavigation = .init()
		viewModel = .init(useCase: mainUseCase, linkNavigation: linkNavigation)
	}

	@Test func handleUpdateButtonTap() async throws {
		try await Task.sleep(for: .seconds(2))
		#expect(linkNavigation.openedUrl == nil)
		#expect(mainUseCase.lastAppVersionPrompt == nil)
		viewModel.handleUpdateButtonTap()
		#expect(linkNavigation.openedUrl == DisplayedLinks.appstore.linkURL)
		#expect(mainUseCase.lastAppVersionPrompt == "1.1.1")
	}

	@Test func handleNoUpdateButtonTap() async throws {
		try await Task.sleep(for: .seconds(1))
		#expect(linkNavigation.openedUrl == nil)
		viewModel.handleNoUpdateButtonTap()
		#expect(mainUseCase.lastAppVersionPrompt == "1.1.1")
	}
}

//
//  StationRewardsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct StationRewardsViewModelTests {
	let viewModel: StationRewardsViewModel
	let useCase: MockRewardsUseCase
	let containerDelegate: StationDetailsContainerDelegate

	init() {
		useCase = .init()
		containerDelegate = .init()
		viewModel = .init(deviceId: "124",
						  containerDelegate: containerDelegate,
						  useCase: useCase)
	}

    @Test func refresh() async throws {
		#expect(!containerDelegate.shouldRefreshCalled)
		try await confirmation { confirm in
			viewModel.refresh {
				#expect(containerDelegate.shouldRefreshCalled)
				confirm()
			}
			try await Task.sleep(for: .seconds(1))
		}
    }

	@Test func retry() async throws {
		#expect(!containerDelegate.shouldRefreshCalled)
		viewModel.handleRetryButtonTap()
		try await Task.sleep(for: .seconds(1))
		#expect(containerDelegate.shouldRefreshCalled)
	}
}

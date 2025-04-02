//
//  StationForecastViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM

@MainActor
struct StationForecastViewModelTests {
	let viewModel: StationForecastViewModel
	let meUseCase: MockMeUseCase
	let containerDelegate: StationDetailsContainerDelegate

	init() {
		containerDelegate = .init()
		meUseCase = MockMeUseCase()
		viewModel = .init(containerDelegate: containerDelegate,
						  useCase: meUseCase)
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
		viewModel.hadndleRetryButtonTap()
		try await Task.sleep(for: .seconds(1))
		#expect(containerDelegate.shouldRefreshCalled)
	}

	@Test func infoTap() {
		#expect(!viewModel.showTemperatureBarsInfo)
		viewModel.handleNextSevenDaysInfoTap()
		#expect(viewModel.showTemperatureBarsInfo)
	}
}

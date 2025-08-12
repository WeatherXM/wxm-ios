//
//  LocationForecastViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 12/8/25.
//

import Testing
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct LocationForecastViewModelTests {
	let viewModel: LocationForecastViewModel
	let useCase: MockLocationForecastsUseCase

	init() {
		useCase = .init()
		self.viewModel = .init(configuration: .init(forecasts: [.init()],
													selectedforecastIndex: 0,
													selectedHour: nil,
													navigationTitle: "Title",
													navigationSubtitle: nil,
													fontAwesomeState: nil),
							   location: .init(),
							   useCase: useCase)
	}

    @Test func handleTopButtonTap() async throws {
		var savedLocations = useCase.getSavedLocations()
		#expect(savedLocations.isEmpty)

		viewModel.handleTopButtonTap()

		savedLocations = useCase.getSavedLocations()
		#expect(!savedLocations.isEmpty)

		viewModel.handleTopButtonTap()

		savedLocations = useCase.getSavedLocations()
		#expect(savedLocations.isEmpty)
    }
}

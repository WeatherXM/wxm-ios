//
//  StationSupportViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 25/9/25.
//

import Testing
import DomainLayer
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct StationSupportViewModelTests {
	let useCase = MockMeUseCase()
	let viewModel: StationSupportViewModel

	init() {
		viewModel = .init(stationName: "Test", useCase: useCase)
	}

    @Test func refresh() async throws {
		#expect(viewModel.mode == .loading)
		try await confirmation { confirm in
			viewModel.refresh()
			try await Task.sleep(for: .seconds(1))
			#expect(viewModel.mode == .content(markdownString: ""))
			confirm()
		}
    }

}

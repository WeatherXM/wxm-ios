//
//  StationDetailsViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Testing
@testable import WeatherXM

@Suite(.serialized)
@MainActor
struct StationDetailsViewModelTests {
	let viewModel: StationDetailsViewModel

	init() {
		viewModel = .init(deviceId: "0",
						  cellIndex: nil,
						  cellCenter: nil,
						  swinjectHelper: MockSwinject())
	}

	@Test func share() async throws {
		#expect(!viewModel.showShareDialog)
		viewModel.handleShareButtonTap()
		try await Task.sleep(for: .seconds(1))
		#expect(viewModel.showShareDialog)
    }

}

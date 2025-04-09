//
//  ExplorerStationsListViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer

@Suite(.serialized)
@MainActor
struct ExplorerStationsListViewModelTests {

	let viewModel: ExplorerStationsListViewModel
	let useCase: MockExplorerUseCase

	init() {
		useCase = MockExplorerUseCase()
		viewModel = ExplorerStationsListViewModel(useCase: useCase,
												  cellIndex: "",
												  cellCenter: nil)
	}

    @Test func cellInfo() async throws {
		#expect(!viewModel.showInfo)
		viewModel.handleCellCapacityInfoTap()
		#expect(viewModel.showInfo)
    }
}

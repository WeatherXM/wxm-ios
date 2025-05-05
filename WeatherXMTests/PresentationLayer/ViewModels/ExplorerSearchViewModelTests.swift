//
//  ExplorerSearchViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import Testing
@testable import WeatherXM
import CoreLocation

private class SearchDelegate: ExplorerSearchViewModelDelegate {
	var rowTappedCalled = false
	var isSearchActive = false
	var settingsButtonTappedCalled = false
	var networkStatisticsTappedCalled = false

	func rowTapped(coordinates: CLLocationCoordinate2D, deviceId: String?, cellIndex: String?) {
		rowTappedCalled = true
	}
	
	func searchWillBecomeActive(_ active: Bool) {
		isSearchActive = active
	}
	
	func settingsButtonTapped() {
		settingsButtonTappedCalled = true
	}

	func networkStatisticsTapped() {
		networkStatisticsTappedCalled = true
	}
}

private struct NetworkModel: NetworkSearchModel {
	var lat: Double? {
		return 0.0
	}

	var lon: Double? {
		return 0.0
	}

	var deviceId: String? {
		return "124"
	}

	var cellIndex: String? {
		return "1"
	}
}

@Suite(.serialized)
@MainActor
struct ExplorerSearchViewModelTests {
	let viewModel: ExplorerSearchViewModel
	let useCase: MockNetworkUseCase
	private let searchDelegate: SearchDelegate

	init() {
		useCase = MockNetworkUseCase()
		viewModel = ExplorerSearchViewModel(useCase: useCase)
		searchDelegate = SearchDelegate()
		viewModel.delegate = searchDelegate
	}

    @Test func tapOnResult() async throws {
		#expect(!searchDelegate.rowTappedCalled)
		let row = SearchView.Row(title: "",
								 subtitle: nil,
								 networkModel: NetworkModel())
		viewModel.handleTapOnResult(row)
		#expect(searchDelegate.rowTappedCalled)
    }

	@Test func settingsTap() async throws {
		#expect(!searchDelegate.settingsButtonTappedCalled)
		viewModel.handleSettingsButtonTap()
		#expect(searchDelegate.settingsButtonTappedCalled)
	}

	@Test func netStatsTap() {
		#expect(!searchDelegate.networkStatisticsTappedCalled)
		viewModel.handleNetwrorkStatsButtonTap()
		#expect(searchDelegate.networkStatisticsTappedCalled)
	}

	@Test func updateActiveStations() {
		#expect(viewModel.activeStationsCount == "0")
		viewModel.updateActiveStations(count: 1000)
		let comma = Locale.current.groupingSeparator ?? "."
		#expect(viewModel.activeStationsCount == "1\(comma)000")
	}

	@Test func searchTerm() {
		#expect(viewModel.searchTerm.isEmpty)
		viewModel.updateSearchTerm("   ")
		#expect(viewModel.searchTerm.isEmpty)

		viewModel.updateSearchTerm("Test")
		#expect(viewModel.searchTerm == "Test")

		viewModel.updateSearchTerm("   Test   ")
		#expect(viewModel.searchTerm == "Test")
	}
}

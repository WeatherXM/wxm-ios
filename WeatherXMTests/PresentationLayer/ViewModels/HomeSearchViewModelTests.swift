//
//  HomeSearchViewModelTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 12/8/25.
//

import Testing
import DomainLayer
@testable import WeatherXM
import CoreLocation

@Suite(.serialized)
@MainActor
struct HomeSearchViewModelTests {
	let networkUseCase = MockNetworkUseCase()
	let viewModel: HomeSearchViewModel
	fileprivate let delegate: SearchDelegate


	init() {
		delegate = SearchDelegate()
		viewModel = HomeSearchViewModel(useCase: networkUseCase)
		viewModel.delegate = delegate
	}

    @Test func handleTapOnResult() {
		let searchAddress = NetworkSearchAddress(name: "Address",
												 place: "Place",
												 center: .init(lat: 0.0, long: 0.0))
		let result = SearchView.Row(title: "",
									subtitle: nil,
									networkModel: searchAddress)

		viewModel.searchTerm = "Test"
		#expect(delegate.tappedLocation == nil)
		viewModel.handleTapOnResult(result)

		#expect(viewModel.searchTerm.isEmpty)
		#expect(delegate.tappedLocation != nil)
    }

}

fileprivate class SearchDelegate: ExplorerSearchViewModelDelegate {
	var tappedLocation: CLLocationCoordinate2D?

	func rowTapped(coordinates: CLLocationCoordinate2D, deviceId: String?, cellIndex: String?) {
		tappedLocation = coordinates
	}

	func searchWillBecomeActive(_ active: Bool) { }

	func networkStatisticsTapped() { }
}

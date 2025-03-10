//
//  MockDeviceLocationRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Foundation
@testable import DomainLayer
import Combine
import CoreLocation

class MockDeviceLocationRepositoryImpl {
	private let searchResultsSubject = PassthroughSubject<[DeviceLocationSearchResult], Never>()

}

extension MockDeviceLocationRepositoryImpl: DeviceLocationRepository {
	var searchResults: AnyPublisher<[DeviceLocationSearchResult], Never> {
		searchResultsSubject.eraseToAnyPublisher()
	}

	var error: AnyPublisher<DeviceLocationError, Never> {
		let locationError: DeviceLocationError = .searchError
		return Just(locationError).eraseToAnyPublisher()
	}

	func getCountryInfos() -> [CountryInfo]? {
		[]
	}

	func searchFor(_ query: String) {
		let res = DeviceLocationSearchResult(id: "124", description: "Text")
		searchResultsSubject.send([res])
	}

	func locationFromSearchResult(_ suggestion: DeviceLocationSearchResult) -> AnyPublisher<DeviceLocation, Never> {
		let loc = DeviceLocation(id: "124",
								 name: nil,
								 country: nil,
								 countryCode: nil,
								 coordinates: .init(lat: 0.0, long: 0.0))
		return Just(loc).eraseToAnyPublisher()
	}

	func locationFromCoordinates(_ coordinates: LocationCoordinates) -> AnyPublisher<DeviceLocation?, Never> {
		let loc = DeviceLocation(id: "124",
								 name: nil,
								 country: nil,
								 countryCode: nil,
								 coordinates: .init(lat: 0.0, long: 0.0))
		return Just(loc).eraseToAnyPublisher()

	}

	func areLocationCoordinatesValid(_ coordinates: LocationCoordinates) -> Bool {
		true
	}

	func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
		.success(CLLocationCoordinate2D())
	}

}

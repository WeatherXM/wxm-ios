//
//  MockDeviceLocationUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 3/4/25.
//

import DomainLayer
import Combine
import CoreLocation

final class MockDeviceLocationUseCase: DeviceLocationUseCaseApi {
	var searchResults: AnyPublisher<[
		DeviceLocationSearchResult], Never> {
			Just([]).eraseToAnyPublisher()
		}

	nonisolated(unsafe) private(set) var lastSearchQuery: String?

	func getCountryInfos() -> [CountryInfo]? {
		[.init(code: "124")]
	}
	
	func searchFor(_ query: String) {
		lastSearchQuery = query
	}
	
	func locationFromSearchResult(_ searchResult: DeviceLocationSearchResult) -> AnyPublisher<DeviceLocation, Never> {
		let location = DeviceLocation(id: "124",
									  name: nil,
									  country: nil,
									  countryCode: nil,
									  coordinates: .init(lat: 0.0, long: 0.0))
		return Just(location).eraseToAnyPublisher()
	}
	
	func locationFromCoordinates(_ coordinates: LocationCoordinates) -> AnyPublisher<DeviceLocation?, Never> {
		let location = DeviceLocation(id: "124",
									  name: nil,
									  country: nil,
									  countryCode: nil,
									  coordinates: .init(lat: 0.0, long: 0.0))
		return Just(location).eraseToAnyPublisher()
	}
	
	func areLocationCoordinatesValid(_ coordinates: LocationCoordinates) -> Bool {
		true
	}
	
	func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
		.success(.init(latitude: 0, longitude: 0))
	}
	
	func getSuggestedDeviceLocation() -> CLLocationCoordinate2D? {
		nil
	}
}

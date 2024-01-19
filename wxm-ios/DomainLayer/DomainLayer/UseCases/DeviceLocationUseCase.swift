//
//  DeviceLocationUseCase.swift
//  DomainLayer
//
//  Created by Manolis Katsifarakis on 17/10/22.
//

import Combine
import CoreLocation

public struct DeviceLocationUseCase {
    let deviceLocationRepository: DeviceLocationRepository
    public init(deviceLocationRepository: DeviceLocationRepository) {
        self.deviceLocationRepository = deviceLocationRepository
        searchResults = deviceLocationRepository.searchResults
        error = deviceLocationRepository.error
    }

    public let searchResults: AnyPublisher<[DeviceLocationSearchResult], Never>
    public let error: AnyPublisher<DeviceLocationError, Never>

	public func getCountryInfos() -> [CountryInfo]? {
		deviceLocationRepository.getCountryInfos()
	}
	
    public func searchFor(_ query: String) {
        deviceLocationRepository.searchFor(query)
    }

    public func locationFromSearchResult(_ searchResult: DeviceLocationSearchResult) -> AnyPublisher<DeviceLocation, Never> {
        deviceLocationRepository.locationFromSearchResult(searchResult)
    }

    public func locationFromCoordinates(_ coordinates: LocationCoordinates) -> AnyPublisher<DeviceLocation?, Never> {
        deviceLocationRepository.locationFromCoordinates(coordinates)
    }

    public func areLocationCoordinatesValid(_ coordinates: LocationCoordinates) -> Bool {
        deviceLocationRepository.areLocationCoordinatesValid(coordinates)
    }

    public func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
        await deviceLocationRepository.getUserLocation()
    }
}

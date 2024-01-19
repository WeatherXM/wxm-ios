//
//  DeviceLocationRepository.swift
//  DomainLayer
//
//  Created by Manolis Katsifarakis on 16/10/22.
//

import Combine
import CoreLocation

public protocol DeviceLocationRepository {
    var searchResults: AnyPublisher<[DeviceLocationSearchResult], Never> { get }
    var error: AnyPublisher<DeviceLocationError, Never> { get }

	func getCountryInfos() -> [CountryInfo]?
    func searchFor(_ query: String)
    func locationFromSearchResult(_ suggestion: DeviceLocationSearchResult) -> AnyPublisher<DeviceLocation, Never>
    func locationFromCoordinates(_ coordinates: LocationCoordinates) -> AnyPublisher<DeviceLocation?, Never>
    func areLocationCoordinatesValid(_ coordinates: LocationCoordinates) -> Bool
    func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError>
}

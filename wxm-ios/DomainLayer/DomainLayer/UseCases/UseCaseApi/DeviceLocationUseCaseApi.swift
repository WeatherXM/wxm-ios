//
//  DeviceLocationUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Foundation
import Combine
import CoreLocation

public protocol DeviceLocationUseCaseApi: Sendable {
	var searchResults: AnyPublisher<[DeviceLocationSearchResult], Never> { get }
	func getCountryInfos() -> [CountryInfo]?
	func searchFor(_ query: String)
	func locationFromSearchResult(_ searchResult: DeviceLocationSearchResult) -> AnyPublisher<DeviceLocation, Never>
	func locationFromCoordinates(_ coordinates: LocationCoordinates) -> AnyPublisher<DeviceLocation?, Never>
	func areLocationCoordinatesValid(_ coordinates: LocationCoordinates) -> Bool
	func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError>
	func getSuggestedDeviceLocation() -> CLLocationCoordinate2D?
}

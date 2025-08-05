//
//  LocationForecastsUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import Foundation
import Toolkit
import CoreLocation
import Combine
import Alamofire

public protocol LocationForecastsUseCaseApi: Sendable {
	var locationAuthorization: WXMLocationManager.Status { get }
	var savedLocationsPublisher: AnyPublisher<[CLLocationCoordinate2D], Never> { get }
	func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError>
	func getForecast(for location: CLLocationCoordinate2D) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never>
	func getSavedLocations() -> [CLLocationCoordinate2D]
	func saveLocation(_ location: CLLocationCoordinate2D)
	func removeLocation(_ location: CLLocationCoordinate2D)
}

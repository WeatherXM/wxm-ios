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

extension Notification.Name {
	static let savedLocationsUpdated = Notification.Name("locationForecasts.savedLocationsUpdated")
}

public protocol LocationForecastsUseCaseApi: Sendable {
	var locationAuthorization: WXMLocationManager.Status { get }
	var savedLocationsPublisher: NotificationCenter.Publisher { get }
	var maxSavedLocations: Int { get }
	func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError>
	func getForecast(for location: CLLocationCoordinate2D) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never>
	func getSavedLocations() -> [CLLocationCoordinate2D]
	func saveLocation(_ location: CLLocationCoordinate2D)
	func removeLocation(_ location: CLLocationCoordinate2D)
}

//
//  MockLocationForecastsUseCase.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 12/8/25.
//

import Foundation
@testable import DomainLayer
import Toolkit
import CoreLocation
import Alamofire
import Combine

final class MockLocationForecastsUseCase: LocationForecastsUseCaseApi {
	nonisolated(unsafe) private let notificationsPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: .savedLocationsUpdated)
	nonisolated(unsafe) private var savedLocations: [CLLocationCoordinate2D] = []

	var locationAuthorization: WXMLocationManager.Status {
		.authorized
	}

	var savedLocationsPublisher: NotificationCenter.Publisher {
		notificationsPublisher
	}

	var maxSavedLocations: Int {
		5
	}

	func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
		.success(.init())
	}
	
	func getForecast(for location: CLLocationCoordinate2D) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
		let forecast = [NetworkDeviceForecastResponse]()
		let response = DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>(request: nil,
																						   response: nil,
																						   data: nil,
																						   metrics: nil,
																						   serializationDuration: 0,
																						   result: .success(forecast))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getSavedLocations() -> [CLLocationCoordinate2D] {
		savedLocations
	}
	
	func saveLocation(_ location: CLLocationCoordinate2D) {
		savedLocations.append(location)
	}
	
	func removeLocation(_ location: CLLocationCoordinate2D) {
		savedLocations.removeAll { $0.cacheKey == location.cacheKey}
	}
}

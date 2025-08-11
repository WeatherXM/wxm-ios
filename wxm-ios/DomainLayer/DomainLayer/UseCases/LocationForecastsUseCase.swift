//
//  LocationForecastsUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import Foundation
import Toolkit
import CoreLocation
import Alamofire
@preconcurrency import Combine

public struct LocationForecastsUseCase: LocationForecastsUseCaseApi {

	nonisolated(unsafe) private let explorerRepository: ExplorerRepository
	private let userDefaultsRepository: UserDefaultsRepository
	nonisolated(unsafe) private let keychainRepository: KeychainRepository
	private let savedLocationsUDKey = UserDefaults.GenericKey.savedLocations.rawValue
	private let forecastsCacheKey = UserDefaults.GenericKey.savedForecasts.rawValue
	private let cacheInterval: TimeInterval = 15 * 60 * 60
	nonisolated(unsafe) private let notificationsPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: .savedLocationsUpdated)
	nonisolated(unsafe) private let cache: TimeValidationCache<[NetworkDeviceForecastResponse]>
	public var locationAuthorization: WXMLocationManager.Status {
		explorerRepository.locationAuthorization
	}

	public var savedLocationsPublisher: NotificationCenter.Publisher {
		notificationsPublisher
	}

	public var maxSavedLocations: Int {
		keychainRepository.isUserLoggedIn() ? 9 : 1
	}

	public init(explorerRepository: ExplorerRepository,
				userDefaultsRepository: UserDefaultsRepository,
				keychainRepository: KeychainRepository,
				cacheManager: PersistCacheManager) {
		self.explorerRepository = explorerRepository
		self.userDefaultsRepository = userDefaultsRepository
		self.keychainRepository = keychainRepository
		self.cache = .init(persistCacheManager: cacheManager, persistKey: forecastsCacheKey)
	}

	public func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
		await explorerRepository.getUserLocation()
	}

	public func getForecast(for location: CLLocationCoordinate2D) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
		if let cachedForecasts: [NetworkDeviceForecastResponse] = cache.getValue(for: location.cacheKey) {
			let response = DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>(request: nil,
																							   response: nil,
																							   data: nil,
																							   metrics: nil,
																							   serializationDuration: 0,
																							   result: .success(cachedForecasts))
			return Just(response).eraseToAnyPublisher()
		}

		return try explorerRepository.getCellForecast(for: location).flatMap { response in
			if let forecasts = try? response.result.get() {
				cache.insertValue(forecasts, expire: cacheInterval, for: location.cacheKey)
			}

			return Just(response)
		}.eraseToAnyPublisher()
	}

	public func getSavedLocations() -> [CLLocationCoordinate2D] {
		guard let data: Data = userDefaultsRepository.getValue(for: savedLocationsUDKey),
			  let codables = try? JSONDecoder().decode([CodableCoordinate].self, from: data) else {
			return []
		}
		let locations: [CLLocationCoordinate2D]? = codables.map { $0.clLocationCoordinate2D }
		return locations ?? []
	}

	public func saveLocation(_ location: CLLocationCoordinate2D) {
		var locations = getSavedLocations()
		if !locations.contains(where: { $0 ~== location}) {
			locations.append(location)
		}

		if let data = try? JSONEncoder().encode(locations.map { CodableCoordinate($0) }) {
			userDefaultsRepository.saveValue(key: savedLocationsUDKey, value: data)
		}

		NotificationCenter.default.post(name: .savedLocationsUpdated, object: nil)

		WXMAnalytics.shared.setUserProperty(key: .savedLocations, value: .custom("\(locations.count)"))
	}

	public func removeLocation(_ location: CLLocationCoordinate2D) {
		var locations = getSavedLocations()
		locations.removeAll(where: { $0 ~== location})


		if let data = try? JSONEncoder().encode(locations.map { CodableCoordinate($0) }) {
			userDefaultsRepository.saveValue(key: savedLocationsUDKey, value: data)
		}

		NotificationCenter.default.post(name: .savedLocationsUpdated, object: nil)

		WXMAnalytics.shared.setUserProperty(key: .savedLocations, value: .custom("\(locations.count)"))
	}
}

private struct CodableCoordinate: Codable {
	let latitude: Double
	let longitude: Double

	init(_ coordinate: CLLocationCoordinate2D) {
		self.latitude = coordinate.latitude
		self.longitude = coordinate.longitude
	}

	var clLocationCoordinate2D: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
}

private extension CLLocationCoordinate2D {
	var cacheKey: String {
		"\(latitude),\(longitude)"
	}
}

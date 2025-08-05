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
import Combine

public struct LocationForecastsUseCase: LocationForecastsUseCaseApi {

	nonisolated(unsafe) private let explorerRepository: ExplorerRepository
	private let userDefaultsRepository: UserDefaultsRepository
	private let savedLocationsUDKey = UserDefaults.GenericKey.savedLocations.rawValue

	public var locationAuthorization: WXMLocationManager.Status {
		explorerRepository.locationAuthorization
	}

	public var savedLocationsPublisher: AnyPublisher<[CLLocationCoordinate2D], Never> {
		Just([]).eraseToAnyPublisher()
	}

	public init(explorerRepository: ExplorerRepository, userDefaultsRepository: UserDefaultsRepository) {
		self.explorerRepository = explorerRepository
		self.userDefaultsRepository = userDefaultsRepository
	}

	public func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
		await explorerRepository.getUserLocation()
	}

	public func getForecast(for location: CLLocationCoordinate2D) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
		try explorerRepository.getCellForecast(for: location)
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

		if let data = try? JSONEncoder().encode(locations.map(CodableCoordinate.init)) {
			userDefaultsRepository.saveValue(key: savedLocationsUDKey, value: data)
		}
	}

	public func removeLocation(_ location: CLLocationCoordinate2D) {
		var locations = getSavedLocations()
		locations.removeAll(where: { $0 ~== location})
		userDefaultsRepository.saveValue(key: savedLocationsUDKey, value: locations)
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

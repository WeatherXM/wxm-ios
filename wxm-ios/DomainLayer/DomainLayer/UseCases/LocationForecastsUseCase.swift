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

	public var locationAuthorization: WXMLocationManager.Status {
		explorerRepository.locationAuthorization
	}

	public init(explorerRepository: ExplorerRepository) {
		self.explorerRepository = explorerRepository
	}

	public func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
		await explorerRepository.getUserLocation()
	}

	public func getForecast(for location: CLLocationCoordinate2D) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
		try explorerRepository.getCellForecast(for: location)
	}

}

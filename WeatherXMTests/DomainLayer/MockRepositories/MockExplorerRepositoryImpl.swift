//
//  MockExplorerRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Foundation
@testable import DomainLayer
import Toolkit
import CoreLocation
import Combine
import Alamofire

class MockExplorerRepositoryImpl {

}

extension MockExplorerRepositoryImpl: ExplorerRepository {
	var locationAuthorization: WXMLocationManager.Status {
		.authorized
	}
	
	func getUserLocation() async -> Result<CLLocationCoordinate2D, ExplorerLocationError> {
		.success(.init())
	}
	
	func getPublicHexes() throws -> AnyPublisher<DataResponse<[PublicHex], NetworkErrorResponse>, Never> {
		let hex = PublicHex()
		let response = DataResponse<[PublicHex], NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success([hex]))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getPublicDevicesOfHex(index: String) throws -> AnyPublisher<DataResponse<[PublicDevice], NetworkErrorResponse>, Never> {
		let publicDevice = PublicDevice()
		let response = DataResponse<[PublicDevice], NetworkErrorResponse>(request: nil,
																		  response: nil,
																		  data: nil,
																		  metrics: nil,
																		  serializationDuration: 0,
																		  result: .success([publicDevice]))
		return Just(response).eraseToAnyPublisher()
	}
	
	func getPublicDevice(index: String, deviceId: String) throws -> AnyPublisher<DataResponse<PublicDevice, NetworkErrorResponse>, Never> {
		let publicDevice = PublicDevice(cellIndex: index)
		let response = DataResponse<PublicDevice, NetworkErrorResponse>(request: nil,
																		response: nil,
																		data: nil,
																		metrics: nil,
																		serializationDuration: 0,
																		result: .success(publicDevice))
		return Just(response).eraseToAnyPublisher()
	}

	func getCellForecast(for coordinates: CLLocationCoordinate2D) throws -> AnyPublisher<DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>, Never> {
		let forecast = [NetworkDeviceForecastResponse]()
		let response = DataResponse<[NetworkDeviceForecastResponse], NetworkErrorResponse>(request: nil,
																						   response: nil,
																						   data: nil,
																						   metrics: nil,
																						   serializationDuration: 0,
																						   result: .success(forecast))
		return Just(response).eraseToAnyPublisher()
	}
}

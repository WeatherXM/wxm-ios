//
//  MockDeviceInfoRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 10/3/25.
//

import Foundation
@testable import DomainLayer
import Combine
import Alamofire

class MockDeviceInfoRepositoryImpl {

}

extension MockDeviceInfoRepositoryImpl: DeviceInfoRepository {
	func getDeviceInfo(deviceId: String) throws -> AnyPublisher<DataResponse<NetworkDevicesInfoResponse, NetworkErrorResponse>, Never> {
		let info = NetworkDevicesInfoResponse()
		let response = DataResponse<NetworkDevicesInfoResponse, NetworkErrorResponse>(request: nil,
																					  response: nil,
																					  data: nil,
																					  metrics: nil,
																					  serializationDuration: 0,
																					  result: .success(info))
		return Just(response).eraseToAnyPublisher()
	}

	func setFriendlyName(deviceId: String, name: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}

	func deleteFriendlyName(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func disclaimDevice(serialNumber: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func rebootStation(device: DeviceDetails) -> AnyPublisher<RebootStationState, Never> {
		return Just(RebootStationState.connect).eraseToAnyPublisher()
	}
	
	func changeFrequency(device: DeviceDetails, frequency: Frequency) -> AnyPublisher<ChangeFrequencyState, Never> {
		return Just(ChangeFrequencyState.changing).eraseToAnyPublisher()
	}
	
	func getDevicePhotos(deviceId: String) throws -> AnyPublisher<DataResponse<[String], NetworkErrorResponse>, Never> {
		let photos: [String] = []
		let response = DataResponse<[String], NetworkErrorResponse>(request: nil,
																	response: nil,
																	data: nil,
																	metrics: nil,
																	serializationDuration: 0,
																	result: .success(photos))
		return Just(response).eraseToAnyPublisher()
	}
}

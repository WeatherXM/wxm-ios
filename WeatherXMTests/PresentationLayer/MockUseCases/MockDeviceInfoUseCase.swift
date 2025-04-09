//
//  MockDeviceInfoUseCase.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 31/3/25.
//

import Foundation
import DomainLayer
@testable import WeatherXM
import Combine
import Alamofire

final class MockDeviceInfoUseCase: DeviceInfoUseCaseApi {
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
		let emptyEntity = EmptyEntity.emptyValue()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func deleteFriendlyName(deviceId: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity.emptyValue()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func disclaimDevice(serialNumber: String) throws -> AnyPublisher<DataResponse<EmptyEntity, NetworkErrorResponse>, Never> {
		let emptyEntity = EmptyEntity.emptyValue()
		let response = DataResponse<EmptyEntity, NetworkErrorResponse>(request: nil,
																	   response: nil,
																	   data: nil,
																	   metrics: nil,
																	   serializationDuration: 0,
																	   result: .success(emptyEntity))
		return Just(response).eraseToAnyPublisher()
	}
	
	func rebootStation(device: DeviceDetails) -> AnyPublisher<RebootStationState, Never> {
		Just(RebootStationState.connect).eraseToAnyPublisher()
	}
	
	func changeFrequency(device: DeviceDetails, frequency: Frequency) -> AnyPublisher<ChangeFrequencyState, Never> {
		Just(ChangeFrequencyState.changing).eraseToAnyPublisher()
	}
	
	func getDevicePhotos(deviceId: String) async throws -> Result<[NetworkDevicePhotosResponse], NetworkErrorResponse> {
		.success([NetworkDevicePhotosResponse(url: "http://image.com")])
	}
}

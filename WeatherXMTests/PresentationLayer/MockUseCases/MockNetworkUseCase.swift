//
//  MockNetworkUseCasei.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import DomainLayer
import Combine
import Alamofire

final class MockNetworkUseCase: NetworkUseCaseApi {
	nonisolated(unsafe) var insertedSearchDevice: NetworkSearchDevice?
	nonisolated(unsafe) var insertedSearchAddress: NetworkSearchAddress?
	nonisolated(unsafe) var deletedSearchRecent: Bool = false

	func getNetworkStats() throws -> AnyPublisher<DataResponse<NetworkStatsResponse, NetworkErrorResponse>, Never> {
		let statsResponse = NetworkStatsResponse(weatherStations: nil,
												 dataDays: nil,
												 tokens: nil,
												 contracts: nil,
												 lastUpdated: nil)
		let response = DataResponse<NetworkStatsResponse, NetworkErrorResponse>(request: nil,
																				response: nil,
																				data: nil,
																				metrics: nil,
																				serializationDuration: 0,
																				result: .success(statsResponse))
		return Just(response).eraseToAnyPublisher()
	}
	
	func search(term: String, exact: Bool, exclude: SearchExclude?) throws -> AnyPublisher<DataResponse<NetworkSearchResponse, NetworkErrorResponse>, Never> {
		let searchResponse = NetworkSearchResponse(devices: nil, addresses: nil)
		let response = DataResponse<NetworkSearchResponse, NetworkErrorResponse>(request: nil,
																				 response: nil,
																				 data: nil,
																				 metrics: nil,
																				 serializationDuration: 0,
																				 result: .success(searchResponse))
		return Just(response).eraseToAnyPublisher()
	}
	
	func insertSearchRecentDevice(device: NetworkSearchDevice) {
		insertedSearchDevice = device
	}
	
	func insertSearchRecentAddress(address: NetworkSearchAddress) {
		insertedSearchAddress = address
	}
	
	func getSearchRecent() -> [any NetworkSearchItem] {
		[]
	}
	
	func deleteAllRecent() {
		deletedSearchRecent = true
	}
}

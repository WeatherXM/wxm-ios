//
//  MockNetworkRepositoryImpl.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/3/25.
//

import Foundation
@testable import DomainLayer
import Combine
import Alamofire

class MockNetworkRepositoryImpl {
	private(set) var insertedDeviceInDB: Bool = false
	private(set) var insertedAddressInDB: Bool = false
	private(set) var allRecentDeleted: Bool = false
}

extension MockNetworkRepositoryImpl: NetworkRepository {
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

	func performSearch(with term: String, exact: Bool, exclude: SearchExclude?) throws -> AnyPublisher<DataResponse<NetworkSearchResponse, NetworkErrorResponse>, Never> {
		let searchResponse = NetworkSearchResponse(devices: nil, addresses: nil)
		let response = DataResponse<NetworkSearchResponse, NetworkErrorResponse>(request: nil,
																				 response: nil,
																				 data: nil,
																				 metrics: nil,
																				 serializationDuration: 0,
																				 result: .success(searchResponse))
		return Just(response).eraseToAnyPublisher()
	}

	func insertDeviceInDB(_ device: NetworkSearchDevice) {
		insertedDeviceInDB = true
	}

	func insertAddressInDB(_ address: NetworkSearchAddress) {
		insertedAddressInDB = true
	}

	func getSearchRecent() -> [any NetworkSearchItem] {
		[]
	}

	func deleteAllRecent() {
		allRecentDeleted = true
	}

	func getRewardsWithdraw(wallet: String) throws -> AnyPublisher<DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>, Never> {
		let rewardsResponse = NetworkUserRewardsResponse(proof: nil,
														 cumulativeAmount: nil,
														 cycle: nil,
														 available: nil,
														 totalClaimed: nil)
		let response = DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>(request: nil,
																					  response: nil,
																					  data: nil,
																					  metrics: nil,
																					  serializationDuration: 0,
																					  result: .success(rewardsResponse))
		return Just(response).eraseToAnyPublisher()		
	}
}

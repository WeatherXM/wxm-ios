//
//  NetworkUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Combine
import Alamofire
import Foundation

public protocol NetworkUseCaseApi: Sendable {
	func getNetworkStats() throws -> AnyPublisher<DataResponse<NetworkStatsResponse, NetworkErrorResponse>, Never>
	func search(term: String, exact: Bool, exclude: SearchExclude?) throws -> AnyPublisher<DataResponse<NetworkSearchResponse, NetworkErrorResponse>, Never>
	func insertSearchRecentDevice(device: NetworkSearchDevice)
	func insertSearchRecentAddress(address: NetworkSearchAddress)
	func getSearchRecent() -> [any NetworkSearchItem]
	func deleteAllRecent()
}

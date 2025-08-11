//
//  NetworkRepository.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 12/6/23.
//

import Foundation
import Combine
import Alamofire

public protocol NetworkRepository {
    func getNetworkStats() throws -> AnyPublisher<DataResponse<NetworkStatsResponse, NetworkErrorResponse>, Never>
    func performSearch(with term: String, exact: Bool, exclude: SearchExclude?) throws -> AnyPublisher<DataResponse<NetworkSearchResponse, NetworkErrorResponse>, Never>
    func insertDeviceInDB(_ device: NetworkSearchDevice)
    func insertAddressInDB(_ address: NetworkSearchAddress)
    func getSearchRecent() -> [any NetworkSearchItem]
    func deleteAllRecent()
	func getRewardsWithdraw(wallet: String) throws -> AnyPublisher<DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>, Never>
}

public enum SearchExclude: String, Sendable {
    case places
	case stations
}

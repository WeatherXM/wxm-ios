//
//  NetworkUseCase.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 12/6/23.
//

import Foundation
import Combine
import Alamofire

public struct NetworkUseCase: NetworkUseCaseApi {

	nonisolated(unsafe) private let repository: NetworkRepository
    public init(repository: NetworkRepository) {
        self.repository = repository
    }

    public func getNetworkStats() throws -> AnyPublisher<DataResponse<NetworkStatsResponse, NetworkErrorResponse>, Never> {
        try repository.getNetworkStats()
    }

    public func search(term: String, exact: Bool = false, exclude: SearchExclude? = nil) throws ->
        AnyPublisher<DataResponse<NetworkSearchResponse, NetworkErrorResponse>, Never> {
            try repository.performSearch(with: term, exact: exact, exclude: exclude)
    }

    public func insertSearchRecentDevice(device: NetworkSearchDevice) {
        repository.insertDeviceInDB(device)
    }

    public func insertSearchRecentAddress(address: NetworkSearchAddress) {
        repository.insertAddressInDB(address)
    }

    public func getSearchRecent() -> [any NetworkSearchItem] {
        repository.getSearchRecent()
    }

    public func deleteAllRecent() {
        repository.deleteAllRecent()
    }
}

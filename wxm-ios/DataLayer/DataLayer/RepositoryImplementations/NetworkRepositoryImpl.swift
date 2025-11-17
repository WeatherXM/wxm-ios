//
//  NetworkRepositoryImpl.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 12/6/23.
//

@preconcurrency import DomainLayer
import Combine
import Alamofire

public struct NetworkRepositoryImpl: NetworkRepository {

    /// The maximum recent results to keep in memory. The purge will ber performed, if needed, on every DB query (`getSearchRecent`)
    private let maxRecentCount = 10
	private let rewardsService: WalletRewardsService

	public init(rewardsService: WalletRewardsService) {
		self.rewardsService = rewardsService
	}

    public func getNetworkStats() throws -> AnyPublisher<DataResponse<DomainLayer.NetworkStatsResponse, DomainLayer.NetworkErrorResponse>, Never> {
        let builder = NetworkApiRequestBuilder.stats
        let request = try builder.asURLRequest()
        return ApiClient.shared.requestCodable(request, mockFileName: builder.mockFileName)
    }

    public func performSearch(with term: String, exact: Bool, exclude: SearchExclude?) throws -> AnyPublisher<DataResponse<NetworkSearchResponse, NetworkErrorResponse>, Never> {
        let builder = NetworkApiRequestBuilder.search(query: term, exact: exact, exclude: exclude?.rawValue)
        let request = try builder.asURLRequest()
        return ApiClient.shared.requestCodable(request, mockFileName: builder.mockFileName)
    }

    public func insertDeviceInDB(_ device: NetworkSearchDevice) {
        guard let dbDevice = device.toManagedObject else {
            return
        }

        dbDevice.timestamp = .now
        DatabaseService.shared.save(object: dbDevice)
    }

    public func insertAddressInDB(_ address: NetworkSearchAddress) {
        guard let dbAddress = address.toManagedObject else {
            return
        }

        dbAddress.timestamp = .now
        DatabaseService.shared.save(object: dbAddress)
    }

    public func getSearchRecent() -> [any NetworkSearchItem] {
        let dbDevices: [DBExplorerSearchEntity] = DatabaseService.shared.fetchExplorerDeviceFromDB()
        let dbAddresses: [DBExplorerSearchEntity] = DatabaseService.shared.fetchExplorerAddressFromDB()
        var results: [DBExplorerSearchEntity] = [dbDevices, dbAddresses].flatMap { $0 }.sorted(by: { ($0.timestamp ?? .now) > ($1.timestamp ?? .now) })

        // Purge recent results
        let redundantResults = results.dropFirst(maxRecentCount)
        results.removeAll(where: { redundantResults.contains($0)})
        redundantResults.forEach { DatabaseService.shared.delete(object: $0) }

        return results.compactMap { result in
            if let dbDevice = result as? DBExplorerDevice {
                return dbDevice.toCodable
            }

            if let dbAddress = result as? DBExplorerAddress {
                return dbAddress.toCodable
            }

            return nil
        }
    }

    public func deleteAllRecent() {
        DatabaseService.shared.deleteExplorerDeviceFromDB()
        DatabaseService.shared.deleteExplorerAddressFromDB()
    }

	public func getRewardsWithdraw(wallet: String) throws -> AnyPublisher<DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>, Never> {
		try rewardsService.getRewardsWithdraw(wallet: wallet)
	}

	public func getCachedRewardsWithdraw(wallet: String) -> NetworkUserRewardsResponse? {
		rewardsService.getCachedRewardsWithdraw(wallet: wallet)
	}
}

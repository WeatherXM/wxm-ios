//
//  WalletRewardsService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 14/11/25.
//

import Foundation
import DomainLayer
import Combine
import Alamofire
import Toolkit

public protocol WalletRewardsService {
	func getCachedRewardsWithdraw(wallet: String) -> NetworkUserRewardsResponse?
	func getRewardsWithdraw(wallet: String) throws -> AnyPublisher<DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>, Never>
}

public class WalletRewardsServiceImpl: WalletRewardsService {
	private let cache: TimeValidationCache<NetworkUserRewardsResponse>
	private let cacheValidationInterval: TimeInterval = 3.0 * 60.0 // 3 minutes

	public init(cacheManager: PersistCacheManager) {
		cache = .init(persistCacheManager: cacheManager, persistKey: String(describing: Self.self))
	}

	public func getCachedRewardsWithdraw(wallet: String) -> NetworkUserRewardsResponse? {
		cache.getValue(for: wallet)
	}
	
	public func getRewardsWithdraw(wallet: String) throws -> AnyPublisher<DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>, Never> {
		let builder = NetworkApiRequestBuilder.rewardsWithdraw(wallet: wallet)
		let urlRequest = try builder.asURLRequest()
		let publisher: AnyPublisher<DataResponse<NetworkUserRewardsResponse, NetworkErrorResponse>, Never> = ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
		return publisher.flatMap { [weak self] response in
			if let rewards = try? response.result.get() {
				self?.cache.insertValue(rewards, expire: self?.cacheValidationInterval ?? 0.0, for: wallet)
			}

			return Just(response)
		}.eraseToAnyPublisher()
	}
}

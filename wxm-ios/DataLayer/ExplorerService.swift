//
//  ExplorerService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 29/9/25.
//

import Foundation
import DomainLayer
import Combine
import Alamofire
import Toolkit

public class ExplorerService {
	private let cacheValidationInterval: TimeInterval = 3.0 * 60.0 // 3 minutes
	private let cache: TimeValidationCache<[PublicHex]>
	private let cacheKey = UserDefaults.GenericKey.explorerHexes.rawValue

	public init(cacheManager: PersistCacheManager) {
		self.cache = .init(persistCacheManager: cacheManager, persistKey: cacheKey)
	}

	func getPublicHexes() throws -> AnyPublisher<DataResponse<[PublicHex], NetworkErrorResponse>, Never> {
		if let cachedValue: [PublicHex] = cache.getValue(for: cacheKey) {
			let response: DataResponse<[PublicHex], NetworkErrorResponse> = .init(request: nil,
																				  response: nil,
																				  data: nil,
																				  metrics: nil,
																				  serializationDuration: 0.0,
																				  result: .success(cachedValue))
			return Just(response).eraseToAnyPublisher()
		}

		let builder = CellRequestBuilder.getCells
		let urlRequest = try builder.asURLRequest()
		let publisher: AnyPublisher<DataResponse<[PublicHex], NetworkErrorResponse>, Never> = ApiClient.shared.requestCodable(urlRequest, mockFileName: builder.mockFileName)
		return publisher.flatMap { [weak self] response in
			guard let self else {
				return Just(response)
			}

			if let value = response.value {
				self.cache.insertValue(value, expire: self.cacheValidationInterval, for: self.cacheKey)
			}

			return Just(response)
		}.eraseToAnyPublisher()
	}
}

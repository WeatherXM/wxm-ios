//
//  MockWalletRewardsService.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 20/11/25.
//

@testable import DataLayer
import Alamofire
import DomainLayer
import Combine

class MockWalletRewardsService: WalletRewardsService {
	func getCachedRewardsWithdraw(wallet: String) -> NetworkUserRewardsResponse? {
		nil
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

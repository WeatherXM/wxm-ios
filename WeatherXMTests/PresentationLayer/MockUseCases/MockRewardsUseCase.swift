//
//  MockRewardsUseCase.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 2/4/25.
//

import DomainLayer

struct MockRewardsUseCase: RewardsUseCaseApi {
	func getDeviceRewardsSummary(deviceId: String) async throws -> Result<NetworkDeviceRewardsSummaryResponse, NetworkErrorResponse> {
		let response = NetworkDeviceRewardsSummaryResponse(totalRewards: 10.0,
														   latest: nil,
														   timeline: nil)
		return .success(response)
	}
}

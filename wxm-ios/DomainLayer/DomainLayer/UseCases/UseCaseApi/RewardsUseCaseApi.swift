//
//  RewardsUseCaseApi.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 1/4/25.
//

import Foundation

public protocol RewardsUseCaseApi: Sendable {
	func getDeviceRewardsSummary(deviceId: String) async throws -> Result<NetworkDeviceRewardsSummaryResponse, NetworkErrorResponse>
}

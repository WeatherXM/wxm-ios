//
//  NetworkDevicesRewardsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 4/9/24.
//

import Foundation

public struct NetworkDevicesRewardsResponse: Codable {
	public let total: Double?
	public let data: [RewardsData]?
}

public extension NetworkDevicesRewardsResponse {
	struct RewardsData: Codable {
		public let ts: Date?
		public let totalRewards: Double?

		enum CodingKeys: String, CodingKey {
			case ts
			case totalRewards = "total_rewards"
		}
	}
}
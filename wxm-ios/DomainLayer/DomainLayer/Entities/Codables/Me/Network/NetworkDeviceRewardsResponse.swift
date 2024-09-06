//
//  NetworkDeviceRewardsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import Foundation

public struct NetworkDeviceRewardsResponse: Codable {
	public let total: Double?
	public let data: [RewardsData]?
	public let details: [Details]?
}

public extension NetworkDeviceRewardsResponse {
	enum RewardType: String, Codable {
		case base
		case boost
	}

	struct RewardsData: Codable {
		public let ts: Date?
		public let rewards: [RewardItem]?
	}

	struct RewardItem: Codable {
		public let type: RewardType?
		public let code: BoostCode?
		public let value: Double?
	}

	struct Details: Codable {
		public let code: BoostCode?
		public let currentRewards: Double?
		public let totalRewards: Double?
		public let boostPeriodStart: Date?
		public let boostPeriodEnd: Date?
		public let completedPercentage: Int?

		enum CodingKeys: String, CodingKey {
			case code
			case currentRewards = "current_rewards"
			case totalRewards = "total_rewards"
			case boostPeriodStart = "boost_period_start"
			case boostPeriodEnd = "boost_period_end"
			case completedPercentage = "completed_percentage"
		}
	}
}

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
	enum RewardType: Codable {
		case base
		case boost
	}

	struct RewardsData: Codable {
		public let ts: Date?
	}

	struct RewardItem: Codable {
		let type: RewardType?
		let code: BoostCode?
		let value: Double?
	}

	struct Details: Codable {
		let code: BoostCode?
		let currentRewards: Double?
		let totalRewards: Double?
		let boostPeriodStart: Date?
		let boostPeriodEnd: Date?
		let completedPercentage: Int?

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
//
//  NetworkDeviceRewardsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 2/9/24.
//

import Foundation

public struct NetworkDeviceRewardsResponse: Codable, Sendable {
	public let total: Double?
	public let data: [RewardsData]?
	public let details: [Details]?

	public init(total: Double?, data: [RewardsData]?, details: [Details]?) {
		self.total = total
		self.data = data
		self.details = details
	}
}

public extension NetworkDeviceRewardsResponse {
	enum RewardType: String, Codable, CaseIterable, Sendable {
		case base
		case boost
		case correction
		case cellBounties = "cell_bounties"
	}

	struct RewardsData: Codable, Sendable {
		public let ts: Date?
		public let rewards: [RewardItem]?

		public init(ts: Date?, rewards: [RewardItem]?) {
			self.ts = ts
			self.rewards = rewards
		}
	}

	struct RewardItem: Codable, Sendable {
		public let type: RewardType?
		public let code: BoostCode?
		public let value: Double?

		public init(type: RewardType?, code: BoostCode?, value: Double?) {
			self.type = type
			self.code = code
			self.value = value
		}
	}

	struct Details: Codable, Sendable {
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

		public init(code: BoostCode?,
					currentRewards: Double?,
					totalRewards: Double?,
					boostPeriodStart: Date?,
					boostPeriodEnd: Date?,
					completedPercentage: Int?) {
			self.code = code
			self.currentRewards = currentRewards
			self.totalRewards = totalRewards
			self.boostPeriodStart = boostPeriodStart
			self.boostPeriodEnd = boostPeriodEnd
			self.completedPercentage = completedPercentage
		}
	}
}

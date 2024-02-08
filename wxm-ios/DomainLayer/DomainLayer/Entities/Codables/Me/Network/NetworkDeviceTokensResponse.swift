//
//  NetworkDeviceTokensResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 27/10/23.
//

import Foundation

public struct NetworkDeviceTokensResponse: Codable {
	public let totalRewards: Double?
	public let latest: DeviceRewardsOverview?
	public let weekly: DeviceRewardsOverview?
	public let monthly: DeviceRewardsOverview?

	enum CodingKeys: String, CodingKey {
		case totalRewards = "total_rewards"
		case latest
		case weekly
		case monthly
	}
}

public struct DeviceRewardsOverview: Codable {
	public let lostRewards: Double?
	public let timestamp: Date?
	public let txHash: String?
	public let fromDate: Date?
	public let toDate: Date?
	public let rewardScore: Int?
	public let periodMaxReward: Double?
	public let actualReward: Double?
	public let timeline: DeviceRewardsTimeline?
	public let rewardAnnotations: [RewardAnnotation]?

	enum CodingKeys: String, CodingKey {
		case lostRewards = "lost_rewards"
		case timestamp
		case txHash = "tx_hash"
		case fromDate = "from_date"
		case toDate = "to_date"
		case rewardScore = "reward_score"
		case periodMaxReward = "period_max_reward"
		case actualReward = "actual_reward"
		case timeline
		case rewardAnnotations = "reward_annotations"
	}

	init(lostRewards: Double?,
		 timestamp: Date?,
		 txHash: String?,
		 fromDate: Date?,
		 toDate: Date?,
		 rewardScore: Int?,
		 periodMaxReward: Double?,
		 actualReward: Double?,
		 timeline: DeviceRewardsTimeline?,
		 errors: DeviceAnnotations?,
		 rewardAnnotations: [RewardAnnotation]?) {
		self.lostRewards = lostRewards
		self.timestamp = timestamp
		self.txHash = txHash
		self.fromDate = fromDate
		self.toDate = toDate
		self.rewardScore = rewardScore
		self.periodMaxReward = periodMaxReward
		self.actualReward = actualReward
		self.timeline = timeline
		self.rewardAnnotations = rewardAnnotations
	}

	public init(datum: Datum) {
		self.init(lostRewards: datum.lostRewards,
				  timestamp: datum.timestamp?.timestampToDate(),
				  txHash: "",
				  fromDate: nil,
				  toDate: nil,
				  rewardScore: datum.rewardScore,
				  periodMaxReward: datum.dailyReward,
				  actualReward: datum.actualReward,
				  timeline: datum.timeline,
				  errors: datum.annotations,
				  rewardAnnotations: datum.rewardAnnotations)
	}
}

public struct DeviceRewardsTimeline: Codable, Hashable {
	public let referenceDate: Date?
	public let rewardScores: [Int]?

	enum CodingKeys: String, CodingKey {
		case referenceDate = "reference_date"
		case rewardScores = "reward_scores"
	}
}

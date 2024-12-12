//
//  NetworkDeviceRewardsSummaryResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 20/2/24.
//

import Foundation

public struct NetworkDeviceRewardsSummaryResponse: Codable, Hashable, Sendable {
	public let totalRewards: Double?
	public let latest: NetworkDeviceRewardsSummary?
	public let timeline: [NetworkDeviceRewardsSummaryTimelineEntry]?

	enum CodingKeys: String, CodingKey {
		case totalRewards = "total_rewards"
		case latest
		case timeline
	}
}

public struct NetworkDeviceRewardsSummary: Codable, Hashable, Sendable {
	public let timestamp: Date?
	public let baseReward: Double?
	public let totalBoostReward: Double?
	public let totalReward: Double?
	public let baseRewardScore: Int?
	public let annotationSummary: [RewardAnnotation]?

	enum CodingKeys: String, CodingKey {
		case timestamp
		case baseReward = "base_reward"
		case totalBoostReward = "total_business_boost_reward"
		case totalReward = "total_reward"
		case baseRewardScore = "base_reward_score"
		case annotationSummary = "annotation_summary"
	}

	public init(timestamp: Date?, baseReward: Double?, totalBoostReward: Double?, totalReward: Double?, baseRewardScore: Int?, annotationSummary: [RewardAnnotation]?) {
		self.timestamp = timestamp
		self.baseReward = baseReward
		self.totalBoostReward = totalBoostReward
		self.totalReward = totalReward
		self.baseRewardScore = baseRewardScore
		self.annotationSummary = annotationSummary
	}
}

public struct NetworkDeviceRewardsSummaryTimelineEntry: Codable, Hashable, Sendable {
	public let timestamp: Date?
	public let baseRewardScore: Int?

	enum CodingKeys: String, CodingKey {
		case timestamp
		case baseRewardScore = "base_reward_score"
	}
}

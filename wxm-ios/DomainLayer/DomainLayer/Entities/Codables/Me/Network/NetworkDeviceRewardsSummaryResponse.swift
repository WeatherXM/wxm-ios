//
//  NetworkDeviceRewardsSummaryResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 20/2/24.
//

import Foundation

struct NetworkDeviceRewardsSummaryResponse: Codable {
	public let totalRewards: Double?
	public let timeline: [NetworkDeviceRewardsTimelineEntry]?
}

struct NetworkDeviceRewardsSummary: Codable {
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
}

struct NetworkDeviceRewardsTimelineEntry: Codable {
	public let timestamp: Date?
	public let baseRewardScore: Int?

	enum CodingKeys: String, CodingKey {
		case timestamp
		case baseRewardScore = "base_reward_score"
	}
}

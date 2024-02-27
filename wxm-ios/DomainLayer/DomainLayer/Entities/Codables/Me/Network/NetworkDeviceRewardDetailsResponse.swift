//
//  NetworkDeviceRewardDetailsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 27/2/24.
//

import Foundation

public struct NetworkDeviceRewardDetailsResponse: Codable, Hashable {
	public let totalDailyReward: Double?
	public let base: Base?
	public let boost: Boost?
}

public extension NetworkDeviceRewardDetailsResponse {
	struct Base: Codable, Hashable {
		let actualReward: Double?
		let rewardScore: Int?
		let maxReward: Double?

		enum CodingKeys: String, CodingKey {
			case actualReward = "actual_reward"
			case rewardScore = "reward_score"
			case maxReward = "max_reward"
		}
	}

	struct Boost: Codable, Hashable {
		let totalReward: Double?
		let data: [BoostReward]?
	}

	struct BoostReward: Codable, Hashable {
		let title: String?
		let description: String?
		let actualReward: Double?
		let rewardScore: Int?
		let maxReward: Double?

		enum CodingKeys: String, CodingKey {
			case title
			case description
			case actualReward = "actual_reward"
			case rewardScore = "reward_score"
			case maxReward = "max_reward"
		}
	}

	struct Annotation: Codable {
		let score: Int?
		let summary: [NetworkDeviceRewardsSummary]?
	}
}

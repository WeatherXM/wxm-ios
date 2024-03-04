//
//  NetworkDeviceRewardDetailsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 27/2/24.
//

import Foundation

public struct NetworkDeviceRewardDetailsResponse: Codable, Hashable {
	public let timestamp: Date?
	public let totalDailyReward: Double?
	public let annotations: [RewardAnnotation]?
	public let base: Base?
	public let boost: Boost?

	enum CodingKeys: String ,CodingKey {
		case timestamp
		case totalDailyReward = "total_daily_reward"
		case annotations = "annotation_summary"
		case base
		case boost
	}
}

public extension NetworkDeviceRewardDetailsResponse {
	struct Base: Codable, Hashable {
		public let actualReward: Double?
		public let rewardScore: Int?
		public let maxReward: Double?
		public let qodScore: Int?
		public let cellCapacity: Int?
		public let cellPosition: Int?

		enum CodingKeys: String, CodingKey {
			case actualReward = "actual_reward"
			case rewardScore = "reward_score"
			case maxReward = "max_reward"
			case qodScore = "qod_score"
			case cellCapacity = "cell_capacity"
			case cellPosition = "cell_position"
		}
	}

	struct Boost: Codable, Hashable {
		public let totalReward: Double?
		public let data: [BoostReward]?

		enum CodingKeys: String, CodingKey {
			case totalReward = "total_daily_reward"
			case data
		}
	}

	struct BoostReward: Codable, Hashable {
		public let code: String?
		public let title: String?
		public let description: String?
		public let imageUrl: String?
		public let docUrl: String?
		public let actualReward: Double?
		public let rewardScore: Int?
		public let maxReward: Double?

		enum CodingKeys: String, CodingKey {
			case code
			case title
			case description
			case imageUrl = "img_url"
			case docUrl = "doc_url"
			case actualReward = "actual_reward"
			case rewardScore = "reward_score"
			case maxReward = "max_reward"
		}
	}
}

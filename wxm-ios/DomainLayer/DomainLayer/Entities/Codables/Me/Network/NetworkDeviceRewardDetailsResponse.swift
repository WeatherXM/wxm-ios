//
//  NetworkDeviceRewardDetailsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 27/2/24.
//

import Foundation

public struct NetworkDeviceRewardDetailsResponse: Codable, Hashable, Sendable {
	public let timestamp: Date?
	public let totalDailyReward: Double?
	public let annotations: [RewardAnnotation]?
	public let base: Base?
	public let boost: Boost?
	public let rewardSplit: [RewardSplit]?

	enum CodingKeys: String, CodingKey {
		case timestamp
		case totalDailyReward = "total_daily_reward"
		case annotations = "annotation_summary"
		case base
		case boost
		case rewardSplit = "reward_split"
	}

	public init(timestamp: Date?,
				totalDailyReward: Double?,
				annotations: [RewardAnnotation]?,
				base: Base?,
				boost: Boost?,
				rewardSplit: [RewardSplit]?) {
		self.timestamp = timestamp
		self.totalDailyReward = totalDailyReward
		self.annotations = annotations
		self.base = base
		self.boost = boost
		self.rewardSplit = rewardSplit
	}
}

public extension NetworkDeviceRewardDetailsResponse {
	struct Base: Codable, Hashable, Sendable {
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

	struct Boost: Codable, Hashable, Sendable {
		public let totalReward: Double?
		public let data: [BoostReward]?

		enum CodingKeys: String, CodingKey {
			case totalReward = "total_daily_reward"
			case data
		}
	}

	struct BoostReward: Codable, Hashable, Sendable {
		public let code: BoostCode?
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

		public init(code: BoostCode?, title: String?, description: String?, imageUrl: String?, docUrl: String?, actualReward: Double?, rewardScore: Int?, maxReward: Double?) {
			self.code = code
			self.title = title
			self.description = description
			self.imageUrl = imageUrl
			self.docUrl = docUrl
			self.actualReward = actualReward
			self.rewardScore = rewardScore
			self.maxReward = maxReward
		}
	}
}

public enum BoostCode: Codable, RawRepresentable, Hashable, Comparable, Sendable {
	case betaReward
	case unknown(String)

	public init?(rawValue: String) {
		switch rawValue {
			case "beta_rewards":
				self = .betaReward
			default:
				self = .unknown(rawValue)
		}
	}

	public var rawValue: String {
		switch self {
			case .betaReward:
				return "beta_rewards"
			case .unknown(let raw):
				return raw
		}
	}
}

public struct RewardSplit: Codable, Hashable, Sendable {
	public let stake: Double?
	public let wallet: String?
	public let reward: Double?

	public init(stake: Double?, wallet: String?, reward: Double?) {
		self.stake = stake
		self.wallet = wallet
		self.reward = reward
	}
}

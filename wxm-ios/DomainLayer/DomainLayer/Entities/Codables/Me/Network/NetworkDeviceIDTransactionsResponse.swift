//
//  NetworkDeviceIDTransactionsResponse.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 18/5/22.
//

import Foundation
import SwiftUI

// MARK: - NetworkDeviceIDTokensTransactionsResponse

public struct NetworkDeviceIDTokensTransactionsResponse: Codable {
    public var data: [Datum]? = [Datum]()
    public var totalPages: Int? = 0
    public var hasNextPage: Bool? = false

    public init() {}

    enum CodingKeys: String, CodingKey {
        case data
        case totalPages = "total_pages"
        case hasNextPage = "has_next_page"
    }
}

// MARK: - Datum

public struct Datum: Codable, Hashable {
    public var timestamp: String? = "-"
	public var lostRewards: Double?
    public var rewardScore: Int? = 0
    public var dailyReward: Double? = 0.0
    public var actualReward: Double? = 0.0
    public var totalRewards: Double? = 0.0
	public var timeline: DeviceRewardsTimeline?
	public var annotations: DeviceAnnotations?
    public init() {}

    enum CodingKeys: String, CodingKey {
        case timestamp
		case lostRewards = "lost_rewards"
        case rewardScore = "reward_score"
        case dailyReward = "daily_reward"
        case actualReward = "actual_reward"
        case totalRewards = "total_rewards"
		case annotations
		case timeline
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try? values.decode(String.self, forKey: .timestamp)
		lostRewards = try? values.decode(Double.self, forKey: .lostRewards)
        rewardScore = try? values.decode(Int.self, forKey: .rewardScore)
        dailyReward = try? values.decode(Double.self, forKey: .dailyReward)
        actualReward = try? values.decode(Double.self, forKey: .actualReward)
        totalRewards = try? values.decode(Double.self, forKey: .totalRewards)
		timeline = try? values.decode(DeviceRewardsTimeline.self, forKey: .timeline)
		annotations = try? values.decodeIfPresent(DeviceAnnotations.self, forKey: .annotations)
    }
}

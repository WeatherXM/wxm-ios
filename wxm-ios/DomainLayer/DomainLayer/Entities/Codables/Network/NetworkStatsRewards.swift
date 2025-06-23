//
//  NetworkStatsRewards.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 17/6/25.
//

import Foundation

public struct NetworkStatsRewards: Codable, Sendable {
	public let last30Days: Int?
	public let last30DaysGraph: [NetworkStatsTimeSeries]?
	public let lastRun: Int?
	public let lastTxHashUrl: String?
	public let tokenMetrics: NetworkStatsTokenMetrics?
	public let total: Int?

	enum CodingKeys: String, CodingKey {
		case last30Days = "last_30days"
		case last30DaysGraph = "last_30days_graph"
		case lastRun = "last_run"
		case lastTxHashUrl = "last_tx_hash_url"
		case tokenMetrics = "token_metrics"
		case total
	}
}

public struct NetworkStatsTokenMetrics: Codable, Sendable {
	public let token: NetworkStatsToken?
	public let totalAllocated: NetworkStatsTotalAllocated?

	enum CodingKeys: String, CodingKey {
		case token
		case totalAllocated = "total_allocated"
	}
}

public struct NetworkStatsToken: Codable, Sendable {
	public let circulatingSupply: Int?
	public let totalSupply: Int?

	enum CodingKeys: String, CodingKey {
		case circulatingSupply = "circulating_supply"
		case totalSupply = "total_supply"
	}

	public init(circulatingSupply: Int?, totalSupply: Int?) {
		self.circulatingSupply = circulatingSupply
		self.totalSupply = totalSupply
	}
}

public struct NetworkStatsTotalAllocated: Codable, Sendable {
	public let baseRewards: Int?
	public let boostRewards: Int?
	public let dune: NetworkStatsDune?

	enum CodingKeys: String, CodingKey {
		case baseRewards = "base_rewards"
		case boostRewards = "boost_rewards"
		case dune
	}
}

public struct NetworkStatsDune: Codable, Sendable {
	public let claimed: Int?
	public let dunePublicUrl: String?
	public let total: Int?
	public let unclaimed: Int?

	enum CodingKeys: String, CodingKey {
		case claimed
		case dunePublicUrl = "dune_public_url"
		case total
		case unclaimed
	}
}

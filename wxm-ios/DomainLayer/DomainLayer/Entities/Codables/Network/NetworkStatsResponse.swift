//
//  NetworkStatsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 12/6/23.
//

import Foundation

public struct NetworkStatsResponse: Codable, Sendable {
    public let weatherStations: NetworkWeatherStations?
	public let contracts: NetworkStatsContracts?
	public let rewards: NetworkStatsRewards?
	public let health: NetworkStatsHealth?
	public let growth: NetworkStatsGrowth?
    public let lastUpdated: Date?

    enum CodingKeys: String, CodingKey {
        case weatherStations = "weather_stations"
		case contracts
		case rewards
		case health = "net_health"
		case growth = "net_growth"
        case lastUpdated = "last_updated"
    }

	public init(weatherStations: NetworkWeatherStations?,
				tokens: NetworkStationsStatsTokens?,
				contracts: NetworkStatsContracts?,
				rewards: NetworkStatsRewards?,
				health: NetworkStatsHealth?,
				growth: NetworkStatsGrowth?,
				lastUpdated: Date?) {
		self.weatherStations = weatherStations
		self.contracts = contracts
		self.rewards = rewards
		self.health = health
		self.growth = growth
		self.lastUpdated = lastUpdated
	}
}

public struct NetworkWeatherStations: Codable, Sendable {
    public let onboarded: NetworkStationsStats?
    public let claimed: NetworkStationsStats?
    public let active: NetworkStationsStats?
}

public struct NetworkStationsStats: Codable, Sendable {
    public let total: Int?
    public let details: [NetworkStationsStatsDetails]?
}

public struct NetworkStationsStatsDetails: Codable, Sendable {
    public let model: String?
    public let connectivity: Connectivity?
    public let amount: Int?
    public let percentage: Float?
    public let url: String?
}

public struct NetworkStationsStatsTokens: Codable, Sendable {
    public let totalSupply: Int?
	public let circulatingSupply: Int?
	public let totalAllocated: Double?
    public let allocatedPerDay: [NetworkStatsTimeSeries]?
	public let lastTxHashUrl: String?
    public let averageMonthly: Double?

    enum CodingKeys: String, CodingKey {
        case totalSupply = "total_supply"
		case circulatingSupply = "circulating_supply"
		case totalAllocated = "total_allocated"
		case lastTxHashUrl = "last_tx_hash_url"
        case allocatedPerDay = "allocated_per_day"
        case averageMonthly = "avg_monthly"
    }

	public init(totalSupply: Int?,
				circulatingSupply: Int?,
				totalAllocated: Double?,
				allocatedPerDay: [NetworkStatsTimeSeries]?,
				lastTxHashUrl: String?,
				averageMonthly: Double?) {
		self.totalSupply = totalSupply
		self.circulatingSupply = circulatingSupply
		self.totalAllocated = totalAllocated
		self.allocatedPerDay = allocatedPerDay
		self.lastTxHashUrl = lastTxHashUrl
		self.averageMonthly = averageMonthly
	}
}

public struct NetworkStatsContracts: Codable, Sendable {
	public let tokenUrl: String?
	public let rewardsUrl: String?

	enum CodingKeys: String, CodingKey {
		case tokenUrl = "token_url"
		case rewardsUrl = "rewards_url"
	}
}

public struct NetworkStatsTimeSeries: Codable, Sendable {
    public let ts: Date?
    public let value: Double?
}

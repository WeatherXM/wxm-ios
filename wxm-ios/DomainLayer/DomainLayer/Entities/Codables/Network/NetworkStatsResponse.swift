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

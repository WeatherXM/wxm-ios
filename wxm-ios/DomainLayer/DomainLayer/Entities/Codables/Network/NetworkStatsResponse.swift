//
//  NetworkStatsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 12/6/23.
//

import Foundation

public struct NetworkStatsResponse: Codable {
    public let weatherStations: NetworkWeatherStations?
    public let dataDays: [NetworkStatsTimeSeries]?
    public let tokens: NetworkStationsStatsTokens?
    public let lastUpdated: Date?

    enum CodingKeys: String ,CodingKey {
        case weatherStations = "weather_stations"
        case dataDays = "data_days"
        case tokens
        case lastUpdated = "last_updated"
    }
}

public struct NetworkWeatherStations: Codable {
    public let onboarded: NetworkStationsStats?
    public let claimed: NetworkStationsStats?
    public let active: NetworkStationsStats?
}

public struct NetworkStationsStats: Codable {
    public let total: Int?
    public let details: [NetworkStationsStatsDetails]?
}

public struct NetworkStationsStatsDetails: Codable {
    public let model: String?
    public let connectivity: Connectivity?
    public let amount: Int?
    public let percentage: Float?
    public let url: String?
}

public struct NetworkStationsStatsTokens: Codable {
    public let totalSupply: Int?
	public let circulatingSupply: Int?
	public let totalAllocated: Double?
    public let allocatedPerDay: [NetworkStatsTimeSeries]?
	public let lastTxHash: String?
    public let averageMonthly: Double?

    enum CodingKeys: String, CodingKey {
        case totalSupply = "total_supply"
		case circulatingSupply = "circulating_supply"
		case totalAllocated = "total_allocated"
		case lastTxHash = "last_tx_hash"
        case allocatedPerDay = "allocated_per_day"
        case averageMonthly = "avg_monthly"
    }
}
public struct NetworkStatsTimeSeries: Codable {
    public let ts: Date?
    public let value: Double?
}

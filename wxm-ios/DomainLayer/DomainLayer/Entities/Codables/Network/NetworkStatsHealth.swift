//
//  NetworkStatsHealth.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 18/6/25.
//

import Foundation

public struct NetworkStatsHealth: Codable, Sendable {
	public let activeStations: Int?
	public let health30DaysGraph: [NetworkStatsTimeSeries]?
	public let networkAvgQod: Int?
	public let networkUptime: Int?

	enum CodingKeys: String, CodingKey {
		case activeStations = "active_stations"
		case health30DaysGraph = "health_30days_graph"
		case networkAvgQod = "network_avg_qod"
		case networkUptime = "network_uptime"
	}
}

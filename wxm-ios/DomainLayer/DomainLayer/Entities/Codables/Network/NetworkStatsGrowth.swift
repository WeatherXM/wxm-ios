//
//  NetworkStatsGrowth.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 19/6/25.
//

import Foundation

public struct NetworkStatsGrowth: Codable, Sendable {
	public let last30Days: Int?
	public let last30DaysGraph: [NetworkStatsTimeSeries]?
	public let networkScaleUp: Int?
	public let networkSize: Int?

	enum CodingKeys: String, CodingKey {
		case last30Days = "last_30days"
		case last30DaysGraph = "last_30days_graph"
		case networkScaleUp = "network_scale_up"
		case networkSize = "network_size"
	}
}

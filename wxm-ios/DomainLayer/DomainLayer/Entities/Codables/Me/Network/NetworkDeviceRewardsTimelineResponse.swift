//
//  NetworkDeviceRewardsTimelineResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 20/2/24.
//

import Foundation

public struct NetworkDeviceRewardsTimelineResponse: Codable, Sendable, Equatable {
	public let data: [NetworkDeviceRewardsSummary]?
	public let totalPages: Int?
	public let hasNextPage: Bool?

	enum CodingKeys: String, CodingKey {
		case data
		case totalPages = "total_pages"
		case hasNextPage = "has_next_page"
	}
}

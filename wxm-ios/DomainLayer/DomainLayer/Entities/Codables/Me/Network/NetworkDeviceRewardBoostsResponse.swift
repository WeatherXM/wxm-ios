//
//  NetworkDeviceRewardBoostsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import Foundation

public struct NetworkDeviceRewardBoostsResponse: Codable, Hashable, Sendable {
	public let code: BoostCode?
	public let metadata: Metadata?
	public let details: Details?
}

public extension NetworkDeviceRewardBoostsResponse {
	struct Metadata: Codable, Hashable, Sendable {
		public let title: String?
		public let description: String?
		public let imageUrl: String?
		public let docUrl: String?
		public let about: String?
		
		enum CodingKeys: String, CodingKey {
			case title
			case description
			case imageUrl = "img_url"
			case docUrl = "doc_url"
			case about
		}
	}

	struct Details: Codable, Hashable, Sendable {
		public let stationHours: Int?
		public let maxDailyReward: Double?
		public let maxTotalReward: Double?
		public let boostStartDate: Date?
		public let boostStopDate: Date?
		public let participationStartDate: Date?
		public let participationStopDate: Date?

		enum CodingKeys: String, CodingKey {
			case stationHours = "station_hours"
			case maxDailyReward = "max_daily_reward"
			case maxTotalReward = "max_total_reward"
			case boostStartDate = "boost_start_date"
			case boostStopDate = "boost_stop_date"
			case participationStartDate = "participation_start_date"
			case participationStopDate = "participation_stop_date"
		}
	}
}

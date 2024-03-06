//
//  NetworkDeviceRewardBoostsResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 6/3/24.
//

import Foundation

public struct NetworkDeviceRewardBoostsResponse: Codable, Hashable {
	public let code: BoostCode?
	public let metadata: Metadata?
	public let details: Details?
}

public extension NetworkDeviceRewardBoostsResponse {
	struct Metadata: Codable, Hashable {
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

	struct Details: Codable, Hashable {
		public let stationHours: Int?
		public let maxDailyReward: Double?
		public let maxTotalReward: Double?
		public let boostStartDate: Date?
		public let boostStopDate: Date?
		public let participationStartDate: Date?
		public let participationStopDate: Date?
	}
}

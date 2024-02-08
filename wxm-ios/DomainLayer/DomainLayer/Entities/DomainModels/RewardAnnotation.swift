//
//  RewardAnnotation.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 8/2/24.
//

import Foundation

public struct RewardAnnotation: Codable, Equatable, Hashable {
	public let severity: Severity?
	public let group: Group?
	public let title: String?
	public let message: String?
	public let docUrl: String?

	enum CodingKeys: String, CodingKey {
		case severity
		case group
		case title
		case message
		case docUrl = "doc_url"
	}
}

public extension RewardAnnotation {
	enum Severity: Codable {
		case info
		case warning
		case error
	}

	enum Group: String, Codable {
		case noWallet = "NO_WALLET"
		case noStationData = "NO_STATION_DATA"
		case sensorProblems = "SENSOR_PROBLEMS"
		case weatherDataGaps = "WEATHER_DATA_GAPS"
		case badStationDeployment = "BAD_STATION_DEPLOYMENT"
		case noLocationData = "NO_LOCATION_DATA"
		case locationNotVerified = "LOCATION_NOT_VERIFIED"
		case userRelocationPenalty = "USER_RELOCATION_PENALTY"
	}
}

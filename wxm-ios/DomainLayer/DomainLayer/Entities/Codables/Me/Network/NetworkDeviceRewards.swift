//
//  NetworkDeviceRewards.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 27/10/23.
//

import Foundation

public struct NetworkDeviceRewards: Codable {
	public let totalRewards: Double?
	public let latest: DeviceRewardsOverview?
	public let weekly: DeviceRewardsOverview?
	public let monthly: DeviceRewardsOverview?

	enum CodingKeys: String, CodingKey {
		case totalRewards = "total_rewards"
		case latest
		case weekly
		case monthly
	}
}

public struct DeviceRewardsOverview: Codable {
	public let totalRewards: Double?
	public let timestamp: Date?
	public let txHash: String?
	public let fromDate: Date?
	public let toDate: Date?
	public let rewardScore: Double?
	public let dailyMaxReward: Double?
	public let actualReward: Double?
	public let timeline: DeviceRewardsTimeline?
	public let errors: DeviceErrors?

	enum CodingKeys: String, CodingKey {
		case totalRewards = "total_rewards"
		case timestamp
		case txHash = "tx_hash"
		case fromDate = "from_date"
		case toDate = "to_date"
		case rewardScore = "reward_score"
		case dailyMaxReward = "daily_max_reward"
		case actualReward = "actual_reward"
		case timeline
		case errors
	}
}

public struct DeviceRewardsTimeline: Codable {
	public let timestamp: Date?
	public let rewardScores: [Double]?

	enum CodingKeys: String, CodingKey {
		case timestamp
		case rewardScores = "reward_scores"
	}
}

public struct DeviceErrors: Codable, Hashable, Equatable {
	public let qod: [DeviceError]?
	public let pol: [DeviceError]?
	public let rm: [DeviceError]?
}

public struct DeviceError: Codable, Hashable, Equatable {
	public let error: ErrorType?
	public let ratio: Double?
	public let affects: [AffectedParameter]?

	public init(error: ErrorType?, ratio: Double?, affects: [AffectedParameter]?) {
		self.error = error
		self.ratio = ratio
		self.affects = affects
	}

	public static func == (lhs: DeviceError, rhs: DeviceError) -> Bool {
		lhs.error == rhs.error &&
		lhs.ratio == rhs.ratio &&
		lhs.affects == rhs.affects
	}
}

public extension DeviceError {
	enum ErrorType: String, Codable, CaseIterable {
		case obc = "OBC"
		case spikes = "SPIKES"
		case noMedian = "NO_MEDIAN"
		case noData = "NO_DATA"
		case shortConst = "SHORT_CONST"
		case longConst = "LONG_CONST"
		case frozenSensor = "FROZEN_SENSOR"
		case locationNotVerified = "LOCATION_NOT_VERIFIED"
		case noLocationData = "NO_LOCATION_DATA"
		case noWallet = "NO_WALLET"
		case cellCapacityReached = "CELL_CAPACITY_REACHED"
	}

	struct AffectedParameter: Codable, Hashable, Equatable {
		public let ratio: Double?
		public let parameter: WeatherField?
	}
}

public enum WeatherField: String, CaseIterable, Codable {
	case temperature
	case feelsLike = "feels_like"
	case humidity
	case wind
	case precipitationRate = "precipitation_rate"
	case precipitationProbability = "precipitation_probability"
	case dailyPrecipitation = "daily_precipitation"
	case windGust = "wind_gust"
	case pressure
	case solarRadiation = "solar_radiation"
	case dewPoint = "dew_point"
	case uv
}

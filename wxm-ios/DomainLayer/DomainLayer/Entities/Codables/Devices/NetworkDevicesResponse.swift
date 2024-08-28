//
//  NetworkDevicesResponse.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import CoreLocation
import Foundation

public struct NetworkDevicesResponse: Codable, Identifiable {
    public var id: String? = ""
    public var name: String = ""
    public var label: String? = ""
    public var location: LocationCoordinates?
	public var batteryState: BatteryState?
    public var timezone: String? = ""
    public var address: String? = ""
    public var attributes: Attributes = .init()
    public var currentWeather: CurrentWeather?
    public var rewards: Rewards? = .init()
    public var relation: DeviceRelation?
	public var bundle: StationBundle?

    public init() {}

    enum CodingKeys: String, CodingKey {
        case id, name, timezone, address, attributes, location, rewards, label, relation, bundle
		case batteryState = "bat_state"
        case currentWeather = "current_weather"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decodeIfPresent(String.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        label = try? values.decodeIfPresent(String.self, forKey: .label)
        location = try? values.decodeIfPresent(LocationCoordinates.self, forKey: .location)
		batteryState = try? values.decodeIfPresent(BatteryState.self, forKey: .batteryState)
        timezone = try? values.decodeIfPresent(String.self, forKey: .timezone)
        address = try? values.decodeIfPresent(String.self, forKey: .address)
        attributes = try values.decodeIfPresent(Attributes.self, forKey: .attributes) ?? Attributes()
        currentWeather = try? values.decodeIfPresent(CurrentWeather.self, forKey: .currentWeather)
        rewards = try values.decodeIfPresent(Rewards.self, forKey: .rewards) ?? Rewards()
        relation = try? values.decodeIfPresent(DeviceRelation.self, forKey: .relation)
		bundle = try? values.decodeIfPresent(StationBundle.self, forKey: .bundle)
    }
}

// MARK: - Attributes

public struct Attributes: Codable {
    public var isActive: Bool = false
    public var lastActiveAt: String? = ""
    public var claimedAt: String? = ""
    public var hex3: Hex? = Hex()
    public var hex7: Hex? = Hex()
    public var firmware: Firmware?
    public var friendlyName: String? = ""

    public init() {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? false
        lastActiveAt = try container.decodeIfPresent(String.self, forKey: .lastActiveAt)
        claimedAt = try container.decodeIfPresent(String.self, forKey: .claimedAt)
        hex3 = try container.decodeIfPresent(Hex.self, forKey: .hex3)
        hex7 = try container.decodeIfPresent(Hex.self, forKey: .hex7)
        firmware = try container.decodeIfPresent(Firmware.self, forKey: .firmware)
        friendlyName = try container.decodeIfPresent(String.self, forKey: .friendlyName)
    }
}

// MARK: - Hex for Hex3 and Hex7

public struct Hex: Codable {
    public var index: String? = ""
    public var polygon: [LocationCoordinates]? = [LocationCoordinates]()
    public var center: LocationCoordinates?
}

// MARK: - CurrentWeather

public struct CurrentWeather: Codable {
    public var timestamp: String? = ""
    public var temperature: Double? = 0.0
    public var temperatureMax: Double? = 0.0
    public var temperatureMin: Double? = 0.0
    public var humidity: Int? = 0
    public var windSpeed: Double? = 0.0
    public var windGust: Double? = 0.0
    public var windDirection: Int? = 0
    public var uvIndex: Int? = 0
    public var precipitation: Double? = 0.0
    public var precipitationProbability: Double? = 0.0
    public var precipitationAccumulated: Double? = 0.0
    public var dewPoint: Double? = 0.0
    public var solarIrradiance: Double? = 0.0
    public var cloudCover: Double? = 0.0
    public var pressure: Double? = 0.0
    public var icon: String? = ""
    public var feelsLike: Double? = 0.0
    public init() {}

    enum CodingKeys: String, CodingKey {
        case timestamp, temperature, humidity
        case temperatureMax = "temperature_max"
        case temperatureMin = "temperature_min"
        case windSpeed = "wind_speed"
        case windGust = "wind_gust"
        case windDirection = "wind_direction"
        case uvIndex = "uv_index"
        case dewPoint = "dew_point"
        case solarIrradiance = "solar_irradiance"
        case precipitation, pressure, icon
        case precipitationProbability = "precipitation_probability"
        case precipitationAccumulated = "precipitation_accumulated"
		case precipitationIntensity = "precipitation_intensity"
        case cloudCover = "cloud_cover"
        case feelsLike = "feels_like"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)
        self.temperature = try container.decodeIfPresent(Double.self, forKey: .temperature)
        self.humidity = try container.decodeIfPresent(Int.self, forKey: .humidity)
        self.temperatureMax = try container.decodeIfPresent(Double.self, forKey: .temperatureMax)
        self.temperatureMin = try container.decodeIfPresent(Double.self, forKey: .temperatureMin)
        self.windSpeed = try container.decodeIfPresent(Double.self, forKey: .windSpeed)
        self.windGust = try container.decodeIfPresent(Double.self, forKey: .windGust)
        self.windDirection = try container.decodeIfPresent(Int.self, forKey: .windDirection)
        self.uvIndex = try container.decodeIfPresent(Int.self, forKey: .uvIndex)
        self.solarIrradiance = try container.decodeIfPresent(Double.self, forKey: .solarIrradiance)
        self.dewPoint = try container.decodeIfPresent(Double.self, forKey: .dewPoint)
        self.precipitation = try container.decodeIfPresent(Double.self, forKey: .precipitation)
        self.pressure = try container.decodeIfPresent(Double.self, forKey: .pressure)
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.precipitationProbability = try container.decodeIfPresent(Double.self, forKey: .precipitationProbability)
		
		// The following value may come in different keys
        self.precipitationAccumulated = (try? container.decodeIfPresent(Double.self, forKey: .precipitationAccumulated)) ??
		(try? container.decodeIfPresent(Double.self, forKey: .precipitationIntensity))

        self.cloudCover = try container.decodeIfPresent(Double.self, forKey: .cloudCover)
        self.feelsLike = try container.decodeIfPresent(Double.self, forKey: .feelsLike)
    }

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(timestamp, forKey: .timestamp)
		try container.encodeIfPresent(temperature, forKey: .temperature)
		try container.encodeIfPresent(humidity, forKey: .humidity)
		try container.encodeIfPresent(temperatureMax, forKey: .temperatureMax)
		try container.encodeIfPresent(temperatureMin, forKey: .temperatureMin)
		try container.encodeIfPresent(windSpeed, forKey: .windSpeed)
		try container.encodeIfPresent(windGust, forKey: .windGust)
		try container.encodeIfPresent(windDirection, forKey: .windDirection)
		try container.encodeIfPresent(uvIndex, forKey: .uvIndex)
		try container.encodeIfPresent(solarIrradiance, forKey: .solarIrradiance)
		try container.encodeIfPresent(dewPoint, forKey: .dewPoint)
		try container.encodeIfPresent(precipitation, forKey: .precipitation)
		try container.encodeIfPresent(pressure, forKey: .pressure)
		try container.encodeIfPresent(icon, forKey: .icon)
		try container.encodeIfPresent(precipitationProbability, forKey: .precipitationProbability)
		try container.encodeIfPresent(precipitationAccumulated, forKey: .precipitationAccumulated)
		try container.encodeIfPresent(cloudCover, forKey: .cloudCover)
		try container.encodeIfPresent(feelsLike, forKey: .feelsLike)
	}

    public init(timestamp: String?,
         temperature: Double?,
         temperatureMax: Double?,
         temperatureMin: Double?,
         humidity: Int?,
         windSpeed: Double?,
         windGust: Double?,
         windDirection: Int?,
         uvIndex: Int?,
         precipitation: Double?,
         precipitationProbability: Double?,
         precipitationAccumulated: Double?,
         dewPoint: Double?,
         solarIrradiance: Double?,
         cloudCover: Double?,
         pressure: Double?,
         icon: String?,
         feelsLike: Double?) {
        self.timestamp = timestamp
        self.temperature = temperature
        self.humidity = humidity
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.windSpeed = windSpeed
        self.windGust = windGust
        self.windDirection = windDirection
        self.uvIndex = uvIndex
        self.solarIrradiance = solarIrradiance
        self.dewPoint = dewPoint
        self.precipitation = precipitation
        self.pressure = pressure
        self.icon = icon
        self.precipitationProbability = precipitationProbability
        self.precipitationAccumulated = precipitationAccumulated
        self.cloudCover = cloudCover
        self.feelsLike = feelsLike
    }
}

public struct Rewards: Codable {
    public var totalRewards: Double? = 0.0
    public var actualReward: Double? = 0.0

    enum CodingKeys: String, CodingKey {
        case totalRewards = "total_rewards"
        case actualReward = "actual_reward"
    }
}

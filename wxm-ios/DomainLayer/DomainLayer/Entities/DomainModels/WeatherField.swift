//
//  WeatherField.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 2/11/23.
//

import Foundation

public enum WeatherField: String, CaseIterable, Codable {
	case temperature
	case feelsLike = "feels_like"
	case humidity
	case wind = "wind_speed"
	case windDirection = "wind_direction"
	case precipitation = "precipitation"
	case precipitationProbability = "precipitation_probability"
	case dailyPrecipitation = "precipitation_accumulated"
	case windGust = "wind_gust"
	case pressure
	case solarRadiation = "solar_radiation"
	case illuminance
	case dewPoint = "dew_point"
	case uv
}

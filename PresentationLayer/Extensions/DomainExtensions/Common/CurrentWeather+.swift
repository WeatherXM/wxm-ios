//
//  CurrentWeather+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/3/23.
//

import Foundation
import DomainLayer
import Toolkit

extension CurrentWeather: Identifiable {
    public var id: String {
        timestamp ?? ""
    }

	func updatedAtString(with timeZone: TimeZone) -> String? {
		guard let date = timestamp?.timestampToDate(timeZone: timeZone) else {
            return nil
        }

		return LocalizableString.lastUpdated(date.localizedDateString(timezone: timeZone)).localized
    }
}

// MARK: - Mock

extension CurrentWeather {
    static var mockInstance: CurrentWeather {
        var currentWeather = CurrentWeather()
        currentWeather.timestamp = Date().ISO8601Format()
		currentWeather.temperature = 24.6
        currentWeather.temperatureMin = 10.0
        currentWeather.temperatureMax = 16.0
        currentWeather.humidity = 30
        currentWeather.windGust = 25.7
        currentWeather.windSpeed = 47.5
        currentWeather.windDirection = 130
        currentWeather.uvIndex = 7
        currentWeather.precipitation = 1.1
		currentWeather.precipitationProbability = 10
        currentWeather.pressure = 603.77
        currentWeather.feelsLike = 18.9
        currentWeather.icon = "drizzle"
        return currentWeather
    }
}

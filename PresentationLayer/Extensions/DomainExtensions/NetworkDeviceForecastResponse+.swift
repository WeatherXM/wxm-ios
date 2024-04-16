//
//  NetworkDeviceForecastResponse+.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import Foundation
import DomainLayer
import Toolkit

extension NetworkDeviceForecastResponse {
	var dailyForecastTemperatureItem: ForecastTemperatureCardView.Item? {
		guard let timezone = TimeZone(identifier: tz) else {
			return nil
		}
		return daily?.toForecastTemperatureItem(with: timezone)
	}
}

extension CurrentWeather {
	func toMiniCardItem(with timeZone: TimeZone, action: VoidCallback? = nil) -> StationForecastMiniCardView.Item {
		.init(time: timestamp?.timestampToDate(timeZone: timeZone).transactionsTimeFormat(timeZone: timeZone) ?? "",
			  animationString: icon?.getAnimationString(),
			  temperature: temperature?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 1) ?? "",
			  action: action)
	}

	func toForecastTemperatureItem(with timeZone: TimeZone) -> ForecastTemperatureCardView.Item {
		.init(weatherIcon: icon?.lottieAnimation,
			  dateString: timestamp?.timestampToDate(timeZone: timeZone).transactionsTimeFormat(timeZone: timeZone) ?? "",
			  temperature: temperature?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 1) ?? "",
			  feelsLike: feelsLike?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 1) ?? "")
	}
}

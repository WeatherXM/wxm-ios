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
	func dailyForecastTemperatureItem(scrollGraphType: ForecastChartType? = nil) ->  ForecastTemperatureCardView.Item? {
		guard let timezone = TimeZone(identifier: tz) else {
			return nil
		}
		return daily?.toForecastTemperatureItem(with: timezone, scrollGraphType: scrollGraphType)
	}
}

extension CurrentWeather {
	func toMiniCardItem(with timeZone: TimeZone, action: VoidCallback? = nil) -> StationForecastMiniCardView.Item {
		.init(time: timestamp?.timestampToDate(timeZone: timeZone).transactionsTimeFormat(timeZone: timeZone) ?? "",
			  animationString: icon?.getAnimationString(),
			  temperature: temperature?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 1) ?? "",
			  action: action)
	}

	func toDailyMiniCardItem(with timeZone: TimeZone, action: VoidCallback? = nil) -> StationForecastMiniCardView.Item {
		.init(time: timestamp?.timestampToDate(timeZone: timeZone).getWeekDay(.abbreviated) ?? "",
			  animationString: icon?.getAnimationString(),
			  temperature: temperatureMax?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 0) ?? "",
			  secondaryTemperature: temperatureMin?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 0) ?? "",
			  action: action)
	}

	func toForecastTemperatureItem(with timeZone: TimeZone, scrollGraphType: ForecastChartType? = nil) -> ForecastTemperatureCardView.Item {
		.init(weatherIcon: icon?.lottieAnimation,
			  dateString: getTemeperatureItemDateString(with: timeZone, timestamp: timestamp),
			  temperature: temperatureMax?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 1) ?? "",
			  secondaryTemperature: temperatureMin?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 1) ?? "",
			  scrollToGraphType: scrollGraphType)
	}

	private func getTemeperatureItemDateString(with timeZone: TimeZone, timestamp: String?) -> String {
		let date = timestamp?.timestampToDate(timeZone: timeZone)
		let relativeDateString = date?.relativeDayStringIfExists(timezone: timeZone)
		let dayString = date?.getFormattedDate(format: .dayShortLiteralMonthDay, timezone: timeZone).capitalized ?? ""

		return [relativeDateString, dayString].compactMap { $0 }.joined(separator: ", ")
	}
}

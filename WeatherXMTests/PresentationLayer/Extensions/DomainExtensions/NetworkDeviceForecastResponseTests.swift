//
//  NetworkDeviceForecastResponseTests.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 29/4/25.
//

import Testing
@testable import WeatherXM
import DomainLayer
import Toolkit

struct NetworkDeviceForecastResponseTests {

	@Test
	func dailyForecastTemperatureItemWithValidTimezoneAndDaily() {
		var response = NetworkDeviceForecastResponse()
		response.tz = "Europe/Athens"
		response.daily = CurrentWeather.mockInstance

		let item = response.dailyForecastTemperatureItem()
		#expect(item != nil)
		#expect(item?.temperature == response.daily?.temperatureMax?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 0))
	}

	@Test
	func dailyForecastTemperatureItemWithInvalidTimezone() {
		var response = NetworkDeviceForecastResponse()
		response.tz = "Invalid/Timezone"
		response.daily = CurrentWeather.mockInstance

		let item = response.dailyForecastTemperatureItem()
		#expect(item == nil)
	}

	@Test
	func dailyForecastTemperatureItemWithNilDaily() {
		var response = NetworkDeviceForecastResponse()
		response.tz = "Europe/Athens"
		response.daily = nil

		let item = response.dailyForecastTemperatureItem()
		#expect(item == nil)
	}

	@Test
	func testToMiniCardItem() {
		let weather = CurrentWeather.mockInstance
		let timeZone = TimeZone(identifier: "Europe/Athens")!
		let item = weather.toMiniCardItem(with: timeZone)

		#expect(item.temperature == weather.temperature?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 1))
		#expect(item.animationString == weather.icon?.getAnimationString())
		#expect(!item.time.isEmpty)
		#expect(!item.precipitation.isEmpty)
	}

	@Test
	func testToDailyMiniCardItem() {
		let weather = CurrentWeather.mockInstance
		let timeZone = TimeZone(identifier: "Europe/Athens")!
		let item = weather.toDailyMiniCardItem(with: timeZone)

		#expect(item.temperature == weather.temperatureMax?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 0))
		#expect(item.secondaryTemperature == weather.temperatureMin?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 0))
		#expect(item.animationString == weather.icon?.getAnimationString())
		#expect(!item.time.isEmpty)
		#expect(!item.precipitation.isEmpty)
	}

	@Test
	func testToForecastTemperatureItem() {
		let weather = CurrentWeather.mockInstance
		let timeZone = TimeZone(identifier: "Europe/Athens")!
		let item = weather.toForecastTemperatureItem(with: timeZone)

		#expect(item.temperature == weather.temperatureMax?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 0))
		#expect(item.secondaryTemperature == weather.temperatureMin?.toTemeratureString(for: WeatherUnitsManager.default.temperatureUnit, decimals: 0))
		#expect(item.weatherIcon == weather.icon?.lottieAnimation)
		#expect(!item.dateString.isEmpty)
	}
}

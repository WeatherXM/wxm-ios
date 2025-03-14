//
//  WeatherFields.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/3/23.
//

import Foundation
import SwiftUI
import DomainLayer
import Toolkit

extension WeatherField: @retroactive CustomStringConvertible {

	static var stationListFields: [WeatherField] {
		[.temperature, .wind, .humidity, .precipitation]
	}

	static var mainFields: [WeatherField] {
		[.humidity, .wind, .precipitation]
	}
	
	static var secondaryFields: [WeatherField] {
		[.windGust, .dailyPrecipitation, .pressure, .dewPoint, .solarRadiation, .uv]
	}
	
	static var hourlyFields: [WeatherField] {
		[.precipitationProbability, .dailyPrecipitation, .wind, .humidity, .pressure, .uv]
	}
	
	static var forecastFields: [WeatherField] {
		[.precipitationProbability, .dailyPrecipitation, .humidity, .wind, .uv, .pressure]
	}
	
	public var description: String {
		switch self {
			case .temperature:
				return LocalizableString.temperature.localized
			case .feelsLike:
				return LocalizableString.feelsLike.localized
			case .humidity:
				return LocalizableString.humidity.localized
			case .wind:
				return LocalizableString.wind.localized
			case .windDirection:
				return LocalizableString.windDirection.localized
			case .precipitation:
				return LocalizableString.precipRate.localized
			case .precipitationProbability:
				return LocalizableString.precipitationProbability.localized
			case .dailyPrecipitation:
				return LocalizableString.dailyPrecipitation.localized
			case .windGust:
				return LocalizableString.windGust.localized
			case .pressure:
				return LocalizableString.pressureAbs.localized
			case .solarRadiation:
				return LocalizableString.solarRadiation.localized
			case .illuminance:
				return LocalizableString.illuminance.localized
			case .dewPoint:
				return LocalizableString.dewPoint.localized
			case .uv:
				return LocalizableString.uv.localized
		}
	}
	
	var displayTitle: String {
		switch self {
			case .temperature:
				return LocalizableString.temperature.localized
			case .feelsLike:
				return LocalizableString.feelsLike.localized
			case .humidity:
				return LocalizableString.humidity.localized
			case .wind:
				return LocalizableString.wind.localized
			case .windDirection:
				return LocalizableString.windDirection.localized
			case .precipitation:
				return LocalizableString.precipitation.localized
			case .precipitationProbability:
				return LocalizableString.precipProbability.localized
			case .dailyPrecipitation:
				return LocalizableString.dailyPrecip.localized
			case .windGust:
				return LocalizableString.windGust.localized
			case .pressure:
				return LocalizableString.pressure.localized
			case .solarRadiation:
				return LocalizableString.solarRadiation.localized
			case .illuminance:
				return LocalizableString.illuminance.localized
			case .dewPoint:
				return LocalizableString.dewPoint.localized
			case .uv:
				return LocalizableString.uvIndex.localized
		}
	}
	
	var legendTitle: String {
		switch self {
			case .precipitationProbability:
				return LocalizableString.probability.localized
			case .wind:
				return LocalizableString.windSpeed.localized
			default:
				return displayTitle
		}
	}
	
	var graphHighlightTitle: String {
		switch self {
			case .temperature:
				return LocalizableString.temperature.localized
			case .feelsLike:
				return LocalizableString.feelsLike.localized
			case .humidity:
				return LocalizableString.humidity.localized
			case .wind:
				return LocalizableString.speed.localized
			case .windDirection:
				return LocalizableString.windDirection.localized
			case .precipitation:
				return LocalizableString.precipitation.localized
			case .precipitationProbability:
				return LocalizableString.precipProbability.localized
			case .dailyPrecipitation:
				return LocalizableString.daily.localized
			case .windGust:
				return LocalizableString.gust.localized
			case .pressure:
				return LocalizableString.pressure.localized
			case .solarRadiation:
				return LocalizableString.solarRadiation.localized
			case .illuminance:
				return LocalizableString.illuminance.localized
			case .dewPoint:
				return LocalizableString.dewPoint.localized
			case .uv:
				return LocalizableString.uvIndex.localized
		}
	}
	
	func fontIcon(from weather: CurrentWeather?) -> (icon: FontIcon, rotation: Double) {
		let rotation = iconRotation(from: weather)
		switch self {
			case .temperature:
				return (.temperatureThreeQuarters, rotation)
			case .feelsLike:
				return (.temperatureThreeQuarters, rotation)
			case .humidity:
				return (.humidity, rotation)
			case .wind:
				// Angle threshold because the original location-arrow doesn't point up
				return (.locationArrow, rotation - 45.0)
			case .windDirection:
				// Angle threshold because the original location-arrow doesn't point up
				return (.locationArrow, rotation - 45.0)
			case .precipitation:
				return (.cloudShowers, rotation)
			case .precipitationProbability:
				return (.umbrella, rotation)
			case .dailyPrecipitation:
				return (.cloudShowers, rotation)
			case .windGust:
				// Angle threshold because the original location-arrow doesn't point up
				return (.locationArrow, rotation - 45.0)
			case .pressure:
				return (.gauge, rotation)
			case .solarRadiation:
				return (.sun, rotation)
			case .illuminance:
				return (.sun, rotation)
			case .dewPoint:
				return (.dropletDegree, rotation)
			case .uv:
				return (.sun, rotation)
		}
	}

	var shouldHaveSpaceWithUnit: Bool {
		let fieldsWithoutSpace: Set<WeatherField> = [.temperature,
													 .feelsLike,
													 .humidity,
													 .precipitationProbability,
													 .dewPoint]
		return !fieldsWithoutSpace.contains(self)
	}
	
	func hourlyIcon(from weather: CurrentWeather?) -> (icon: AssetEnum, rotation: Double) {
		let rotation = iconRotation(from: weather)
		switch self {
			case .temperature:
				return (.temperatureIcon, rotation)
			case .feelsLike:
				return (.temperatureIcon, rotation)
			case .humidity:
				return (.humidityIconSmall, rotation)
			case .wind:
				return (.windDirIconSmall, rotation)
			case .windDirection:
				return (.windDirIconSmall, rotation)
			case .precipitation:
				return (.rainIconSmall, rotation)
			case .precipitationProbability:
				return (.umbrellaIconSmall, rotation)
			case .dailyPrecipitation:
				return (.rainIconSmall, rotation)
			case .windGust:
				return (.windDirIconSmall, rotation)
			case .pressure:
				return (.pressureIconSmall, rotation)
			case .solarRadiation:
				return (.solarIconSmall, rotation)
			case .illuminance:
				return (.solarIconSmall, rotation)
			case .dewPoint:
				return (.humidityIconSmall, rotation)
			case .uv:
				return (.solarIconSmall, rotation)
		}
	}

	private func iconRotation(from weather: CurrentWeather?) -> Double {
		switch self {
			case .wind, .windGust:
				guard let direction = weather?.windDirection else {
					return 0.0
				}
				
				let index = UnitsConverter().getIndexOfCardinal(value: direction)
				return 180.0 + Double(index) * 22.5
			default:
				return 0.0
		}
	}
}

extension WeatherField {
	/// Get `WeatherValueLiterals` for each field
	/// - Parameters:
	///   - weather: The weather object to extract info
	///   - unitsManager: The manager which holds the selected units
	///   - includeDirection: In case of wind fields (`wind` and `windGust`), include or not direction in `WeatherValueLiterals`'s `unit` field
	///   - isForHourlyForecast: There is an inconsistency in the API and the precipitation accumulated value is returned in precipitation field ONLY in hourly forecast.
	///   Pass true when the field will be rendered in hourly forecast.
	/// - Returns: The `WeatherValueLiterals` for each field
	func weatherLiterals(from weather: CurrentWeather?,
						 unitsManager: WeatherUnitsManager,
						 includeDirection: Bool = true,
						 isForHourlyForecast: Bool = false) -> WeatherValueLiterals? {
		guard let weather else {
			return nil
		}
		
		switch self {
			case .temperature:
				return createWeatherLiterals(from: weather.temperature, unitsManager: unitsManager)
			case .feelsLike:
				return createWeatherLiterals(from: weather.feelsLike, unitsManager: unitsManager)
			case .humidity:
				return createWeatherLiterals(from: Double(weather.humidity ?? 0), unitsManager: unitsManager)
			case .wind:
				return createWeatherLiterals(from: weather.windSpeed,
											 addditonalInfo: weather.windDirection,
											 unitsManager: unitsManager,
											 includeDirection: includeDirection,
											 isForHourlyForecast: isForHourlyForecast)
			case .windDirection:
				return nil
			case .precipitation:
				return createWeatherLiterals(from: weather.precipitation, unitsManager: unitsManager)
			case .dailyPrecipitation:
				/// In case of hourly weather forecast the `precipitationAccumulated` is received in `precipitation` property
				/// So ONLY for this case we generate the precipitation accumulated string from different property
				if isForHourlyForecast {
					return createWeatherLiterals(from: weather.precipitation, unitsManager: unitsManager)
				}
				return createWeatherLiterals(from: weather.precipitationAccumulated, unitsManager: unitsManager)
			case .windGust:
				return createWeatherLiterals(from: weather.windGust,
											 addditonalInfo: weather.windDirection,
											 unitsManager: unitsManager,
											 includeDirection: includeDirection)
			case .pressure:
				return createWeatherLiterals(from: weather.pressure, unitsManager: unitsManager)
			case .solarRadiation:
				return createWeatherLiterals(from: weather.solarIrradiance, unitsManager: unitsManager)
			case .illuminance:
				return nil
			case .dewPoint:
				return createWeatherLiterals(from: weather.dewPoint, unitsManager: unitsManager)
			case .uv:
				return createWeatherLiterals(from: Double(weather.uvIndex ?? 0), unitsManager: unitsManager)
			case .precipitationProbability:
				return createWeatherLiterals(from: weather.precipitationProbability, unitsManager: unitsManager)
		}
	}
	
	func createWeatherLiterals(from value: Double?,
							   addditonalInfo: Any? = nil,
							   unitsManager: WeatherUnitsManager,
							   includeDirection: Bool = true,
							   isForHourlyForecast: Bool = false,
							   shouldConvertUnits: Bool = true,
							   isAccumulated: Bool = false) -> WeatherValueLiterals? {
		guard let value, !value.isNaN else {
			return nil
		}
		
		let formatter = WeatherFormatter(shouldConvert: shouldConvertUnits)
		switch self {
			case .temperature, .feelsLike, .dewPoint:
				return formatter.getTemperatureLiterals(temperature: value, unit: unitsManager.temperatureUnit)
			case .humidity:
				return formatter.getHumidityLiterals(value: Int(value))
			case .wind, .windGust:
				return formatter.getWindValueLiterals(value: value,
													  windDirection: addditonalInfo as? Int,
													  speedUnit: unitsManager.windSpeedUnit,
													  directionUnit: unitsManager.windDirectionUnit,
													  includeDirection: includeDirection)
			case .windDirection:
				return nil
			case .precipitation:
				if isAccumulated {
					return formatter.getPrecipitationAccumulatedLiterals(from: value, unit: unitsManager.precipitationUnit)
				}
				return formatter.getPrecipitationLiterals(value: value, unit: unitsManager.precipitationUnit)
			case .precipitationProbability:
				return formatter.getPrecipitationProbabilityLiterals(value: value)
			case .dailyPrecipitation:
				return formatter.getPrecipitationAccumulatedLiterals(from: value, unit: unitsManager.precipitationUnit)
			case .pressure:
				return formatter.getPressureLiterals(pressure: value, unit: unitsManager.pressureUnit)
			case .solarRadiation:
				return formatter.getSolarRadiationLiterals(value: value)
			case .illuminance:
				return nil
			case .uv:
				return formatter.getUVLiterals(value: Int(value))
		}
	}
}

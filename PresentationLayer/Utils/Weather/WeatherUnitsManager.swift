//
//  WeatherUnitsManager.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 28/9/23.
//

import Foundation
import Toolkit
import DomainLayer

class WeatherUnitsManager: ObservableObject {
	
	nonisolated(unsafe) static let `default`: WeatherUnitsManager =  {
		let useCase = SwinjectHelper.shared.getContainerForSwinject().resolve(MainUseCase.self)!
		let manager = WeatherUnitsManager(mainUseCase: useCase)
		
		return manager
	}()

	private let mainUseCase: MainUseCase

	init(mainUseCase: MainUseCase) {
		self.mainUseCase = mainUseCase
		setWeatherUnitsAnalytics()
	}

	var temperatureUnit: TemperatureUnitsEnum {
		get {
			getTemperatureMetricEnum()
		}

		set {
			mainUseCase.saveOrUpdateWeatherMetric(unitProtocol: newValue)
			setWeatherUnitsAnalytics()
		}
	}

	var precipitationUnit: PrecipitationUnitsEnum {
		get {
			getPrecipitationMetricEnum()
		}

		set {
			mainUseCase.saveOrUpdateWeatherMetric(unitProtocol: newValue)
			setWeatherUnitsAnalytics()
		}
	}

	var windSpeedUnit: WindSpeedUnitsEnum {
		get {
			getWindSpeedMetricEnum()
		}

		set {
			mainUseCase.saveOrUpdateWeatherMetric(unitProtocol: newValue)
			setWeatherUnitsAnalytics()
		}
	}

	var windDirectionUnit: WindDirectionUnitsEnum {
		get {
			getWindDirectionMetricEnum()
		}

		set {
			mainUseCase.saveOrUpdateWeatherMetric(unitProtocol: newValue)
			setWeatherUnitsAnalytics()
		}
	}

	var pressureUnit: PressureUnitsEnum {
		get {
			getPressureMetricEnum()
		}

		set {
			mainUseCase.saveOrUpdateWeatherMetric(unitProtocol: newValue)
			setWeatherUnitsAnalytics()
		}
	}

	// MARK: Temperature userDefaults

	private func getTemperatureMetricEnum() -> TemperatureUnitsEnum {
		guard let temperatureUnits = mainUseCase.readOrCreateWeatherMetric(key: UserDefaults.WeatherUnitKey.temperature.rawValue) as? TemperatureUnitsEnum else {
			return .celsius
		}
		return temperatureUnits
	}

	// MARK: Percipitation userDefaults

	private func getPrecipitationMetricEnum() -> PrecipitationUnitsEnum {
		guard let precipitationUnits = mainUseCase.readOrCreateWeatherMetric(key: UserDefaults.WeatherUnitKey.precipitation.rawValue) as? PrecipitationUnitsEnum else {
			return .millimeters
		}
		return precipitationUnits
	}

	// MARK: Wind Speed userDefaults

	private func getWindSpeedMetricEnum() -> WindSpeedUnitsEnum {
		guard let windSpeedUnits = mainUseCase.readOrCreateWeatherMetric(key: UserDefaults.WeatherUnitKey.windSpeed.rawValue) as? WindSpeedUnitsEnum else {
			return .metersPerSecond
		}
		return windSpeedUnits
	}

	// MARK: Wind Direction userDefaults

	private func getWindDirectionMetricEnum() -> WindDirectionUnitsEnum {
		guard let windDirectionUnits = mainUseCase.readOrCreateWeatherMetric(key: UserDefaults.WeatherUnitKey.windDirection.rawValue) as? WindDirectionUnitsEnum else {
			return .cardinal
		}
		return windDirectionUnits
	}

	// MARK: Pressure userDefaults

	private func getPressureMetricEnum() -> PressureUnitsEnum {
		guard let pressureUnits = mainUseCase.readOrCreateWeatherMetric(key: UserDefaults.WeatherUnitKey.pressure.rawValue) as? PressureUnitsEnum else {
			return .hectopascal
		}
		return pressureUnits
	}
}

private extension WeatherUnitsManager {
	func setWeatherUnitsAnalytics() {
		WXMAnalytics.shared.setUserProperty(key: .temperature, value: temperatureUnit.analyticsValue)
		WXMAnalytics.shared.setUserProperty(key: .precipitation, value: precipitationUnit.analyticsValue)
		WXMAnalytics.shared.setUserProperty(key: .wind, value: windSpeedUnit.analyticsValue)
		WXMAnalytics.shared.setUserProperty(key: .windDirection, value: windDirectionUnit.analyticsValue)
		WXMAnalytics.shared.setUserProperty(key: .pressure, value: pressureUnit.analyticsValue)
	}
}

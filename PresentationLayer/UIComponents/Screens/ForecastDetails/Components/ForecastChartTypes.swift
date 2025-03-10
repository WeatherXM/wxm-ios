//
//  ForecastChartTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 18/4/24.
//

import Foundation
import DomainLayer
import DGCharts

enum ForecastChartType: String, ChartCardProtocol {
	case temperature
	case precipitation
	case wind
	case humidity
	case pressure
	case uv

	var scrollId: String {
		self.rawValue
	}
	
	var description: String {
		switch self {
			case .temperature:
				return LocalizableString.temperature.localized
			case .precipitation:
				return LocalizableString.precipitation.localized
			case .wind:
				return LocalizableString.wind.localized
			case .humidity:
				return LocalizableString.humidity.localized
			case .pressure:
				return LocalizableString.pressure.localized
			case .uv:
				return LocalizableString.uvIndex.localized
		}
	}

	var icon: AssetEnum {
		switch self {
			case .temperature:
				return .temperatureIcon
			case .precipitation:
				return .precipitationIcon
			case .wind:
				return .windIcon
			case .humidity:
				return .humidityIcon
			case .pressure:
				return .pressureIcon
			case .uv:
				return .solarIcon
		}
	}

	var weatherFields: [WeatherField] {
		switch self {
			case .temperature:
				return [.temperature, .feelsLike]
			case .precipitation:
				return [.precipitation, .precipitationProbability]
			case .wind:
				return [.wind]
			case .humidity:
				return [.humidity]
			case .pressure:
				return [.pressure]
			case .uv:
				return [.uv]
		}
	}

	var isRightAxisEnabled: Bool {
		let axisDependencies =  weatherFields.map { getAxisDependecy(for: $0) }
		return axisDependencies.contains(.right)
	}

	func getAxisDependecy(for weatherField: WeatherField) -> YAxis.AxisDependency {
		switch self {
			case .temperature, .wind, .humidity, .pressure, .uv:
				return .left
			case .precipitation:
				switch weatherField {
					case .precipitation:
						return .left
					case .precipitationProbability:
						return .right
					default:
						return .left
				}
		}
	}
	
	func configureAxis(leftAxis: YAxis, rightAxis: YAxis, for lineData: LineChartData) {
		switch self {
			case .temperature, .wind, .humidity:
				break
			case .uv:
				leftAxis.axisMinimum = 0.0
			case .precipitation:
				rightAxis.axisMinimum = 0.0
				leftAxis.axisMinimum = 0.0
			case .pressure:
				let isInHg = WeatherUnitsManager.default.pressureUnit == .inchOfMercury
				let yMin = lineData.yMin
				let yMax = lineData.yMax
				if isInHg && (yMax - yMin < 2.0) {
					leftAxis.axisMinimum = yMin - 0.1
					leftAxis.axisMaximum = yMax + 0.1
					rightAxis.axisMinimum = yMin - 0.1
					rightAxis.axisMaximum = yMax + 0.1
				}
		}
	}

	func legendTitle(for weatherField: WeatherField) -> String {
		weatherField.legendTitle
	}

	func highlightTitle(for weatherField: WeatherField) -> String {
		weatherField.graphHighlightTitle
	}

	func getWeatherLiterals(chartEntry: ChartDataEntry?, weatherField: WeatherField) -> WeatherValueLiterals? {
		let literals = weatherField.createWeatherLiterals(from: chartEntry?.y,
														  addditonalInfo: chartEntry?.data,
														  unitsManager: WeatherUnitsManager.default,
														  shouldConvertUnits: false,
														  isAccumulated: true)

		return literals
	}
}

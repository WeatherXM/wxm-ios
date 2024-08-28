//
//  ChartCardTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/5/23.
//

import SwiftUI
import DGCharts
import DomainLayer

enum ChartCardType: String, ChartCardProtocol {
    case temperature
    case precipitation
    case wind
    case humidity
    case pressure
    case solar

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
            case .solar:
                return LocalizableString.solar.localized
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
            case .solar:
                return .solarIcon
        }
    }

    var weatherFields: [WeatherField] {
        switch self {
            case .temperature:
                return [.temperature, .feelsLike]
            case .precipitation:
                return [.precipitation, .dailyPrecipitation]
            case .wind:
                return [.wind, .windGust]
            case .humidity:
                return [.humidity]
            case .pressure:
                return [.pressure]
            case .solar:
                return [.uv, .solarRadiation]
        }
    }

    var isRightAxisEnabled: Bool {
        let axisDependencies =  weatherFields.map { getAxisDependecy(for: $0) }
        return axisDependencies.contains(.right)
    }

    func getAxisDependecy(for weatherField: WeatherField) -> YAxis.AxisDependency {
        switch self {
            case .temperature, .wind, .humidity, .pressure:
                return .left
            case .precipitation:
                switch weatherField {
                    case .precipitation:
                        return .left
                    case .dailyPrecipitation:
                        return .right
                    default:
                        return .left
                }
            case .solar:
                switch weatherField {
                    case .uv:
                        return .left
                    case .solarRadiation:
                        return .right
                    default:
                        return .left
                }
        }
    }

	func configureAxis(leftAxis: YAxis, rightAxis: YAxis, for lineData: LineChartData) {
		switch self {
			case .temperature:
				break
			case .precipitation:
				rightAxis.axisMinimum = 0.0
				leftAxis.axisMinimum = 0.0
			case .wind:
				break
			case .humidity:
				break
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
			case .solar:
				rightAxis.axisMinimum = 0.0
				leftAxis.axisMinimum = 0.0
		}
	}

	func legendTitle(for weatherField: WeatherField) -> String {
		switch weatherField {
			case .precipitation:
				LocalizableString.precipRate.localized
			default:
				weatherField.legendTitle
		}
	}

	func highlightTitle(for weatherField: WeatherField) -> String {
		switch weatherField {
			case .precipitation:
				LocalizableString.maxRate.localized
			default:
				weatherField.graphHighlightTitle
		}
	}

	func getWeatherLiterals(chartEntry: ChartDataEntry?, weatherField: WeatherField) -> WeatherValueLiterals? {
		let literals = weatherField.createWeatherLiterals(from: chartEntry?.y,
														  addditonalInfo: chartEntry?.data,
														  unitsManager: WeatherUnitsManager.default,
														  shouldConvertUnits: false)

		return literals
	}
}

//
//  ChartCardTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/5/23.
//

import SwiftUI
import Charts
import DomainLayer

protocol ChartCardProtocol: CaseIterable, CustomStringConvertible {
	var icon: AssetEnum { get }
	var weatherFields: [WeatherField] { get }
	var isRightAxisEnabled: Bool { get }
	func getAxisDependecy(for weatherField: WeatherField) -> YAxis.AxisDependency
	func configureAxis(leftAxis: YAxis, rightAxis: YAxis, for lineData: LineChartData) 
}


enum ChartCardType: ChartCardProtocol {
    case temperature
    case precipitation
    case wind
    case humidity
    case pressure
    case solar

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
                return [.precipitationRate, .dailyPrecipitation]
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
                    case .precipitationRate:
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
}

class ChartDelegate: ObservableObject, ChartViewDelegate {
    @Published var selectedIndex: Int?

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        selectedIndex = Int(entry.x)
    }
}

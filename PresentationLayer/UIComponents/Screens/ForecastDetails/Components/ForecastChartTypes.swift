//
//  ForecastChartTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 18/4/24.
//

import Foundation
import DomainLayer
import Charts

enum ForecastChartType: ChartCardProtocol {
	case temperature
	case precipitation

	var description: String {
		switch self {
			case .temperature:
				return LocalizableString.temperature.localized
			case .precipitation:
				return LocalizableString.precipitation.localized
		}
	}

	var icon: AssetEnum {
		switch self {
			case .temperature:
				return .temperatureIcon
			case .precipitation:
				return .precipitationIcon
		}
	}

	var weatherFields: [WeatherField] {
		switch self {
			case .temperature:
				return [.temperature, .feelsLike]
			case .precipitation:
				return [.precipitationRate, .precipitationProbability]
		}
	}

	var isRightAxisEnabled: Bool {
		let axisDependencies =  weatherFields.map { getAxisDependecy(for: $0) }
		return axisDependencies.contains(.right)
	}

	func getAxisDependecy(for weatherField: WeatherField) -> YAxis.AxisDependency {
		switch self {
			case .temperature:
				return .left
			case .precipitation:
				switch weatherField {
					case .precipitationRate:
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
			case .temperature:
				break
			case .precipitation:
				rightAxis.axisMinimum = 0.0
				leftAxis.axisMinimum = 0.0
		}
	}
}

//
//  ChartCardTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 11/5/23.
//

import SwiftUI
import Charts
import DomainLayer

enum ChartCardType: CaseIterable, CustomStringConvertible {
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
}

class ChartDelegate: ObservableObject, ChartViewDelegate {
    @Published var selectedIndex: Int?

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        selectedIndex = Int(entry.x)
    }
}

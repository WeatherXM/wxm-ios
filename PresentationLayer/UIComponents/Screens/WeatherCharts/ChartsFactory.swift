//
//  ChartsFactory.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 9/5/23.
//

import Charts
import UIKit
import Toolkit
import DomainLayer

class ChartsFactory {
    private let unitConverter: UnitsConverter
    private let weatherUnitFormatter: WeatherUnitsConverter

    init() {
        unitConverter = UnitsConverter()
        let userDefaultsRepository = SwinjectHelper.shared.getContainerForSwinject().resolve(UserDefaultsRepository.self)!
        weatherUnitFormatter = WeatherUnitsConverter(userDefaultsRepository: userDefaultsRepository, unitConverter: unitConverter)
    }

	func createHourlyCharts(timeZone: TimeZone, startingDate: Date, hourlyWeatherData: [CurrentWeather]) -> WeatherChartModels {
        var entries: [WeatherField: [ChartDataEntry]] = [:]

        var timestamps = [String]()
        let dates = startingDate.dailyHourlySamples(timeZone: timeZone)
        for (index, date) in dates.enumerated() {
            let timestamp = date.toTimestamp(with: timeZone)
            timestamps.append(timestamp.timestampToDate(timeZone: timeZone).twelveHourPeriodTime)
            let xVal = Double(index)

            let element = hourlyWeatherData.first(where: { $0.timestamp == timestamp })
            WeatherField.allCases.forEach { type in
                var chartDataEntry: ChartDataEntry?
                if let element {
                    chartDataEntry = getChartDataEntry(type: type, element: element, xVal: xVal)
                } else {
                    chartDataEntry = ChartDataEntry(x: xVal, y: .nan)
                }

                if let chartDataEntry {
                    var typeEntries: [ChartDataEntry] = entries[type] ?? []
                    typeEntries.append(chartDataEntry)
                    entries[type] = typeEntries
                }
            }
        }

        var dataModels: [WeatherField: WeatherChartDataModel] = [:]
        WeatherField.allCases.forEach {
            dataModels[$0] = WeatherChartDataModel(weatherField: $0,
                                                   timestamps: timestamps,
                                                   entries: entries[$0] ?? [])
        }

        return WeatherChartModels(markDate: startingDate,
                                  tz: timeZone.identifier,
                                  dataModels: dataModels)
    }
}

private extension ChartsFactory {
    func getWindImage(for windDirection: Int) -> UIImage? {
        let index = unitConverter.getIndexOfCardinal(value: windDirection)
        let rotation: Float = 180.0 + Float(index) * 22.5
        let image = UIImage(named: .windDirIconSmall)?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor(colorEnum: .warning)).rotate(degrees: rotation)

        return image
    }

	func getChartDataEntry(type: WeatherField, element: CurrentWeather, xVal: Double) -> ChartDataEntry? {
		var chartDataEntry: ChartDataEntry?
		switch type {
			case .temperature:
				if let temperature = element.temperature {
					chartDataEntry = ChartDataEntry(x: xVal, y: weatherUnitFormatter.convertTemp(value: temperature, decimals: 1))
				}
			case .feelsLike:
				if let feelsLike = element.feelsLike {
					chartDataEntry = ChartDataEntry(x: xVal, y: weatherUnitFormatter.convertTemp(value: feelsLike, decimals: 1))
				}
			case .precipitation:
				if let precipitation = element.precipitation {
					chartDataEntry = ChartDataEntry(x: xVal, y: weatherUnitFormatter.convertPrecipitation(value: precipitation))
				}
			case .wind:
				chartDataEntry = getWindEntry(xVal: xVal, weather: element)
			case .windDirection:
				break
			case .windGust:
				if let windGust = weatherUnitFormatter.convertWindSpeed(value: element.windGust) {
					chartDataEntry = ChartDataEntry(x: xVal, y: windGust, data: element.windDirection)
				}
			case .humidity:
				if let humidity = element.humidity {
					chartDataEntry = ChartDataEntry(x: xVal, y: Double(humidity))
				}
			case .pressure:
				if let pressure = element.pressure {
					chartDataEntry = ChartDataEntry(x: xVal, y: weatherUnitFormatter.convertPressure(value: pressure))
				}
			case .uv:
				if let uvIndex = element.uvIndex {
					chartDataEntry = BarChartDataEntry(x: xVal, y: Double(uvIndex))
				}
			case .precipitationProbability:
				if let precipitationProbability = element.precipitationProbability {
					chartDataEntry = ChartDataEntry(x: xVal, y: precipitationProbability)
				}
			case .dailyPrecipitation:
				if let precipitationAccumulated = element.precipitationAccumulated {
					chartDataEntry = ChartDataEntry(x: xVal, y: weatherUnitFormatter.convertPrecipitation(value: precipitationAccumulated))
				}
			case .solarRadiation:
				if let solarIrradiance = element.solarIrradiance {
					chartDataEntry = ChartDataEntry(x: xVal, y: solarIrradiance)
				}
			case .illuminance:
				break
			case .dewPoint:
				if let dewPoint = element.dewPoint {
					chartDataEntry = ChartDataEntry(x: xVal, y: weatherUnitFormatter.convertTemp(value: dewPoint, decimals: 1))
				}
		}
		
		return chartDataEntry
	}

	func getWindEntry(xVal: Double, weather: CurrentWeather) -> ChartDataEntry? {
		guard let windSpeed = weatherUnitFormatter.convertWindSpeed(value: weather.windSpeed) else {
			return nil
		}

		var windDirectionAsset: UIImage?
		if let windDirection = weather.windDirection, windSpeed > 0 {
			windDirectionAsset = getWindImage(for: windDirection)
		}
		return ChartDataEntry(x: xVal, y: windSpeed, icon: windDirectionAsset, data: weather.windDirection)
	}
}

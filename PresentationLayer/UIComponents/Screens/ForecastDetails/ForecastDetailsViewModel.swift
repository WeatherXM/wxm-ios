//
//  ForecastDetailsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import Foundation
import DomainLayer
import SwiftUI

class ForecastDetailsViewModel: ObservableObject {
	let forecasts: [NetworkDeviceForecastResponse]
	let device: DeviceDetails
	let followState: UserDeviceFollowState?
	@Published private(set) var chartDelegate: ChartDelegate = ChartDelegate()
	@Published var selectedForecastIndex: Int? {
		didSet {
			guard let selectedForecastIndex else {
				return
			}
			currentForecast = forecasts[selectedForecastIndex]
		}
	}
	@Published var currentForecast: NetworkDeviceForecastResponse? {
		didSet {
			updateFieldItems()
			updateHourlyItems()
			updateDailyItems()
			updateCharts()
		}
	}
	@Published private(set) var dailyItems: [StationForecastMiniCardView.Item] = []
	@Published var fieldItems: [ForecastFieldCardView.Item] = []
	@Published private(set) var hourlyItems: [StationForecastMiniCardView.Item] = []
	@Published private(set) var selectedHourlyIndex: Int?
	@Published private(set) var chartModels: HistoryChartModels?

	init(configuration: Configuration) {
		self.forecasts = configuration.forecasts
		self.device = configuration.device
		self.followState = configuration.followState
		if !forecasts.isEmpty {
			self.selectedForecastIndex = configuration.selectedforecastIndex
		}
	}
}

private extension ForecastDetailsViewModel {
	func updateFieldItems() {
		guard let currentForecast else {
			fieldItems = []
			return
		}

		self.fieldItems = WeatherField.forecastFields.compactMap { field in
			guard let daily = currentForecast.daily,
					let literals = field.weatherLiterals(from: daily, unitsManager: .default, includeDirection: true) else {
				return nil
			}

			return ForecastFieldCardView.Item(icon: field.hourlyIcon(),
											  iconRotation: field.iconRotation(from: daily),
											  title: field.displayTitle,
											  value: attributedString(literals: literals))
		}
	}

	func attributedString(literals: WeatherValueLiterals) -> AttributedString {
		let value = literals.value
		let unit = literals.unit

		var attributedString = AttributedString("\(value) \(unit)")
		if let valueRange = attributedString.range(of: value) {
			attributedString[valueRange].foregroundColor = Color(colorEnum: .text)
			attributedString[valueRange].font = .system(size: CGFloat(.mediumFontSize), weight: .bold)
		}

		if let unitRange = attributedString.range(of: unit) {
			attributedString[unitRange].foregroundColor = Color(colorEnum: .darkGrey)
			attributedString[unitRange].font = .system(size: CGFloat(.normalFontSize))
		}

		return attributedString
	}

	func updateHourlyItems() {
		guard let currentForecast,
			  let hourly = currentForecast.hourly, let timezone = TimeZone(identifier: currentForecast.tz) else {
			hourlyItems = []
			return
		}

		hourlyItems = hourly.map { $0.toMiniCardItem(with: timezone)}
		let selectedIndex = hourly.firstIndex(where: { $0.timestamp?.timestampToDate(timeZone: timezone).getHour(with: timezone) == 7})
		self.selectedHourlyIndex = nil
		self.selectedHourlyIndex = selectedIndex
	}

	func updateDailyItems() {
		let dailyForecasts = forecasts.compactMap { $0.daily }
		guard let currentForecast,
			  let timezone = TimeZone(identifier: currentForecast.tz) else {
			dailyItems = []
			return
		}

		dailyItems = dailyForecasts.enumerated().map { index, element in
			return element.toDailyMiniCardItem(with: timezone) { [weak self] in
				self?.selectedForecastIndex = index
			}
		}
	}

	func updateCharts() {
		guard let currentForecast,
			  let timezone = TimeZone(identifier: currentForecast.tz),
			  let date = currentForecast.hourly?.first?.timestamp?.timestampToDate(),
			  let data = currentForecast.hourly else {

			return
		}

		chartDelegate.selectedIndex = 0
		chartModels = ChartsFactory().createHourlyCharts(timeZone: timezone, startingDate: date, hourlyWeatherData: data)
	}
}

extension ForecastDetailsViewModel: HashableViewModel {
	func hash(into hasher: inout Hasher) {
		hasher.combine(device.id)
	}
}

extension ForecastDetailsViewModel {
	struct Configuration {
		let forecasts: [NetworkDeviceForecastResponse]
		let selectedforecastIndex: Int
		let selectedHour: Int?
		let device: DeviceDetails
		let followState: UserDeviceFollowState?
	}
}

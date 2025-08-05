//
//  ForecastDetailsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import Foundation
import DomainLayer
import SwiftUI
import Toolkit

@MainActor
class ForecastDetailsViewModel: ObservableObject {
	let forecasts: [NetworkDeviceForecastResponse]
	let fontIconState: StateFontAwesome?
	let navigationTitle: String
	let navigationSubtitle: String?
	@Published private(set) var isTransitioning: Bool = false
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
			updateDailyItem()
		}
	}
	@Published private(set) var detailsDailyItem: ForecastDetailsDailyView.Item?
	lazy var dailyItems: [StationForecastMiniCardView.Item] = {
		getDailyItems()
	}()

	init(configuration: Configuration) {
		self.forecasts = configuration.forecasts
		self.fontIconState = configuration.fontAwesomeState
		self.navigationTitle = configuration.navigationTitle
		self.navigationSubtitle = configuration.navigationSubtitle
		if !forecasts.isEmpty {
			self.selectedForecastIndex = configuration.selectedforecastIndex
		}
	}
}

private extension ForecastDetailsViewModel {
	func getFieldItems() -> [ForecastFieldCardView.Item] {
		guard let currentForecast else {

			return []
		}

		let fieldItems: [ForecastFieldCardView.Item] = WeatherField.forecastFields.compactMap { field in
			guard let daily = currentForecast.daily,
					let literals = field.weatherLiterals(from: daily,
														 unitsManager: .default,
														 includeDirection: true) else {
				return nil
			}

			let hourlyIcon = field.hourlyIcon(from: daily)
			return ForecastFieldCardView.Item(icon: hourlyIcon.icon,
											  iconRotation: hourlyIcon.rotation,
											  title: field.displayTitle,
											  value: attributedString(literals: literals,
																	  unitWithSpace: field.shouldHaveSpaceWithUnit),
											  scrollToGraphType: getGraphType(for: field))
		}

		return fieldItems
	}

	func getGraphType(for weatherField: WeatherField) -> ForecastChartType? {
		switch weatherField {
			case .temperature:
					.temperature
			case .humidity:
					.humidity
			case .wind:
					.wind
			case .precipitation:
					.precipitation
			case .precipitationProbability:
					.precipitation
			case .dailyPrecipitation:
					.precipitation
			case .pressure:
					.pressure
			case .uv:
					.uv
			default:
				nil
		}
	}

	func attributedString(literals: WeatherValueLiterals, unitWithSpace: Bool) -> AttributedString {
		let value = literals.value
		let unit = literals.unit

		let space: String = unitWithSpace ? " " : ""
		var attributedString = AttributedString("\(value)\(space)\(unit)")
		attributedString.foregroundColor = Color(colorEnum: .darkestBlue)
		attributedString.font = .system(size: CGFloat(.normalFontSize), weight: .bold)

		return attributedString
	}

	func getHourlyItems() -> [StationForecastMiniCardView.Item] {
		guard let currentForecast,
			  let hourly = currentForecast.hourly, let timezone = TimeZone(identifier: currentForecast.tz) else {
			return []
		}

		let hourlyItems: [StationForecastMiniCardView.Item] = hourly.map { $0.toMiniCardItem(with: timezone)}

		return hourlyItems
	}

	func getDailyItems() -> [StationForecastMiniCardView.Item] {
		let dailyForecasts = forecasts.compactMap { $0.daily }
		guard let currentForecast,
			  let timezone = TimeZone(identifier: currentForecast.tz) else {

			return []
		}

		return dailyForecasts.enumerated().map { index, element in
			return element.toDailyMiniCardItem(with: timezone) { [weak self] in
				self?.isTransitioning = true
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					self?.selectedForecastIndex = index
					self?.isTransitioning = false
				}

				WXMAnalytics.shared.trackEvent(.selectContent, parameters: [.contentType: .dailyCard,
																	  .itemId: .dailyDetails])
			}
		}
	}

	func getChartModels() -> WeatherChartModels? {
		guard let currentForecast,
			  let timezone = TimeZone(identifier: currentForecast.tz),
			  let date = currentForecast.hourly?.first?.timestamp?.timestampToDate(),
			  let data = currentForecast.hourly else {

			return nil
		}

		chartDelegate.selectedIndex = 0
		return ChartsFactory().createHourlyCharts(timeZone: timezone, startingDate: date, hourlyWeatherData: data)
	}

	func updateDailyItem() {
		chartDelegate.selectedIndex = 0

		var hourIndex: Int?
		if let timezone = currentForecast?.tz.toTimezone {
			hourIndex = currentForecast?.hourly?.firstIndex(where: { $0.timestamp?.timestampToDate(timeZone: timezone).getHour(with: timezone) == 7})
		}

		let temperatureItem = currentForecast?.dailyForecastTemperatureItem(scrollGraphType: getGraphType(for: .temperature))
		self.detailsDailyItem = .init(temperatureItem: temperatureItem,
									  fieldItems: getFieldItems(),
									  hourlyItems: getHourlyItems(),
									  initialHourlyItemIndex: hourIndex,
									  chartModels: getChartModels(),
									  chartDelegate: chartDelegate)
	}
}

extension ForecastDetailsViewModel: HashableViewModel {
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(navigationTitle)
	}
}

extension ForecastDetailsViewModel {
	struct Configuration {
		let forecasts: [NetworkDeviceForecastResponse]
		let selectedforecastIndex: Int
		let selectedHour: Int?
		let navigationTitle: String
		let navigationSubtitle: String?
		var fontAwesomeState: StateFontAwesome?

		init(forecasts: [NetworkDeviceForecastResponse],
			 selectedforecastIndex: Int,
			 selectedHour: Int?,
			 device: DeviceDetails,
			 followState: UserDeviceFollowState?) {
			self.forecasts = forecasts
			self.selectedforecastIndex = selectedforecastIndex
			self.selectedHour = selectedHour
			self.navigationTitle = device.displayName
			self.navigationSubtitle = device.friendlyName.isNilOrEmpty ? nil : device.name
			self.fontAwesomeState = followState?.state.FAIcon
		}
	}
}

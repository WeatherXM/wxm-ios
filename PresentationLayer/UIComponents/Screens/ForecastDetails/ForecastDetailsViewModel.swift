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
	@Published var currentForecast: NetworkDeviceForecastResponse? {
		didSet {
			updateFieldItems()
			updateHourlyItems()
			updateDailyItems()
		}
	}
	@Published private(set) var dailyItems: [StationForecastMiniCardView.Item] = []
	@Published var fieldItems: [ForecastFieldCardView.Item] = []
	@Published private(set) var hourlyItems: [StationForecastMiniCardView.Item] = []

	init(forecasts: [NetworkDeviceForecastResponse], device: DeviceDetails, followState: UserDeviceFollowState?) {
		self.forecasts = forecasts
		self.device = device
		self.followState = followState
		self.currentForecast = forecasts.first
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
	}

	func updateDailyItems() {
		let dailyForecasts = forecasts.compactMap { $0.daily }
		guard let currentForecast,
			  let timezone = TimeZone(identifier: currentForecast.tz) else {
			dailyItems = []
			return
		}

		dailyItems = dailyForecasts.map { $0.toDailyMiniCardItem(with: timezone)}
	}
}

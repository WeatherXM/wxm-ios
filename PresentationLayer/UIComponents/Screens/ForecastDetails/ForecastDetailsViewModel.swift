//
//  ForecastDetailsViewModel.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 16/4/24.
//

import Foundation
import DomainLayer

class ForecastDetailsViewModel: ObservableObject {
	let forecasts: [NetworkDeviceForecastResponse]
	let device: DeviceDetails
	let followState: UserDeviceFollowState?
	@Published var currentForecast: NetworkDeviceForecastResponse? {
		didSet {
			updateFieldItems()
		}
	}
	@Published var fieldItems: [ForecastFieldCardView.Item] = []

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

			let value = literals.value
			
			return ForecastFieldCardView.Item(icon: field.hourlyIcon(),
											  iconRotation: field.iconRotation(from: daily),
											  title: field.description, 
											  value: value.attributedMarkdown ?? "")
		}
	}
}

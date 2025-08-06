//
//  HomeTypes.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 1/8/25.
//

import DomainLayer
import CoreLocation

enum CurrentLocationViewState {
	case allowLocation
	case forecast(LocationForecast)
	case empty
}

enum SavedLocationsViewState {
	case forecasts([LocationForecast])
	case empty
}

struct LocationForecast: Identifiable {
	var id: String {
		address + icon + temperature
	}

	var hashValue: String {
		id
	}

	let address: String
	let icon: String
	let temperature: String
	let highTemperature: String
	let lowTemperature: String
	var location: CLLocationCoordinate2D?
	var forecasts: [NetworkDeviceForecastResponse]?
}

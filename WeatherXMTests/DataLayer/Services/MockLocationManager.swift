//
//  MockLocationManager.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 7/2/25.
//

import Foundation
import Toolkit
import CoreLocation

struct MockLocationManager: WXMLocationManager.LocationManagerProtocol {
	var status: Toolkit.WXMLocationManager.Status {
		.authorized
	}

	func requestAuthorization() async -> Toolkit.WXMLocationManager.Status {
		.authorized
	}

	func getUserLocation() async -> Result<CLLocationCoordinate2D, WXMLocationManager.LocationError> {
		.success(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
	}
}

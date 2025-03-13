//
//  MockGeocoder.swift
//  WeatherXMTests
//
//  Created by Pantelis Giazitsis on 11/3/25.
//

import Foundation
@testable import DomainLayer
import Toolkit
import CoreLocation

struct MockGeocoder: GeocoderProtocol {
	func resolveAddressLocation(_ location: CLLocationCoordinate2D, completion: @escaping GenericCallback<String>) {
		completion("Resolved address")
	}
	
	func resolveAddressLocation(_ location: CLLocationCoordinate2D) async throws -> String {
		"Resolved address"
	}
}

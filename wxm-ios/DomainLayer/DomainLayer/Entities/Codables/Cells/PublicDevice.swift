//
//  PublicDevice.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

public struct PublicDevice: Codable, Sendable {
    var id: String = ""
    var name: String = ""
    var timezone: String?
    var isActive: Bool?
    var lastWeatherStationActivity: String?
	var address: String?
    var cellIndex: String?
	var cellAvgDataQuality: Double?
	var cellCenter: LocationCoordinates?
    var currentWeather: CurrentWeather?
	var bundle: StationBundle?
	var metrics: Metrics?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case timezone
        case isActive
        case lastWeatherStationActivity
		case address
        case cellIndex
		case cellCenter
		case cellAvgDataQuality
        case currentWeather = "current_weather"
		case bundle
		case metrics
    }
}

//
//  PublicDevice.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

public struct PublicDevice: Codable {
    var id: String = ""
    var name: String = ""
    var timezone: String?
    var isActive: Bool?
    var lastWeatherStationActivity: String?
    var cellIndex: String?
	var cellCenter: LocationCoordinates?
    var currentWeather: CurrentWeather?
	var bundle: StationBundle?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case timezone
        case isActive
        case lastWeatherStationActivity
        case cellIndex
		case cellCenter
        case currentWeather = "current_weather"
		case bundle
    }
}

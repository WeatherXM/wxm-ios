//
//  PublicDevice.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

public struct PublicDevice: Codable {
    var id: String = ""
    var name: String = ""
    var timezone: String? = nil
    var isActive: Bool? = nil
    var lastWeatherStationActivity: String? = nil
    var cellIndex: String? = nil
	var cellCenter: LocationCoordinates?
    var currentWeather: CurrentWeather? = nil
	var bundle: StationBundle? = nil

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

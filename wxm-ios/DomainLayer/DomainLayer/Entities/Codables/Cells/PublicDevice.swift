//
//  PublicDevice.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

public struct PublicDevice: Codable {
    var id: String = ""
    var name: String = ""
    var profile: Profile? = nil
    var timezone: String? = nil
    var isActive: Bool? = nil
    var lastWeatherStationActivity: String? = nil
    var cellIndex: String? = nil
    var currentWeather: CurrentWeather? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case timezone
        case isActive
        case profile
        case lastWeatherStationActivity
        case cellIndex
        case currentWeather = "current_weather"
    }
}

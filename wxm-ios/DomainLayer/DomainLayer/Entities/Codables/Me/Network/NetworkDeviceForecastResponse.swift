//
//  NetworkDeviceForecastResponse.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 18/5/22.
//

import Foundation

public struct NetworkDeviceForecastResponse: Codable {
    public var tz: String = ""
    public var date: String = ""
    public var hourly: [CurrentWeather]? = []
    public var daily: CurrentWeather? = .init()

    public init() {}

    public init(tz: String, date: String, hourly: [CurrentWeather]?, daily: CurrentWeather? = nil) {
        self.tz = tz
        self.date = date
        self.hourly = hourly
        self.daily = daily
    }
}

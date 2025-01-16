//
//  NetworkDeviceHistoryResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 18/5/23.
//

import Foundation

public struct NetworkDeviceHistoryResponse: Codable, Sendable {
    public let tz: String
    public let date: String
    public let hourly: [CurrentWeather]?
    public let daily: CurrentWeather?

    public init(tz: String, date: String, hourly: [CurrentWeather]?, daily: CurrentWeather? = nil) {
        self.tz = tz
        self.date = date
        self.hourly = hourly
        self.daily = daily
    }
}

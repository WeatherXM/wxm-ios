//
//  NetworkDeviceForecastResponse.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 18/5/22.
//

import Foundation

public struct NetworkDeviceForecastResponse: Codable, Sendable {
    public var tz: String = ""
    public var date: String = ""
    public var hourly: [CurrentWeather]? = []
    public var daily: CurrentWeather? = .init()
	public var address: String? = nil

    public init() {}

    public init(tz: String, date: String, hourly: [CurrentWeather]?, daily: CurrentWeather? = nil, address: String? = nil) {
        self.tz = tz
        self.date = date
        self.hourly = hourly
        self.daily = daily
		self.address = address
    }
}

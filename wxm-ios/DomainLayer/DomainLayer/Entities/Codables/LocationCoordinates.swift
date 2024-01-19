//
//  LocationCoordinates.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 22/6/23.
//

import Foundation

public struct LocationCoordinates: Equatable, Codable {
    public let lat: Double
    public let lon: Double

    public init(lat: Double, long: Double) {
        self.lat = lat
        self.lon = long
    }
}

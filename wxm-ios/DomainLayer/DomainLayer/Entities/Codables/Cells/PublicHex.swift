//
//  PublicHex.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

public struct PublicHex: Codable, Sendable {
    public var index: String = ""
    public var deviceCount: Int?
    public var center: HexLocation = .init()
    public var polygon: [HexLocation] = []

    enum CodingKeys: String, CodingKey {
        case index
        case deviceCount = "device_count"
        case center
        case polygon
    }
}

public struct HexLocation: Codable, Sendable {
    public var lat: Double = 0.0
    public var lon: Double = 0.0
}

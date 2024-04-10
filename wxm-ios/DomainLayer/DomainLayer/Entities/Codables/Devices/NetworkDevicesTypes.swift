//
//  NetworkDevicesTypes.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 15/3/23.
//

import Foundation

public struct Firmware: Codable {
    public let assigned: String?
    public let current: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        assigned = try? container.decodeIfPresent(String.self, forKey: .assigned)
        current = try? container.decodeIfPresent(String.self, forKey: .current)
    }

    public init(assigned: String?, current: String?) {
        self.assigned = assigned
        self.current = current
    }
}

public enum Profile: String, Codable {
    case m5 = "M5"
    case helium = "Helium"
}

public enum DeviceRelation: String, Codable {
    case owned
    case followed
}

public enum BatteryState: String, Codable {
	case low
	case ok
}

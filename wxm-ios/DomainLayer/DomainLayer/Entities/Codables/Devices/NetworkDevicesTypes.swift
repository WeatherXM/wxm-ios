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
	case d1 = "D1"
}

public enum DeviceRelation: String, Codable {
    case owned
    case followed
}

public enum BatteryState: String, Codable {
	case low
	case ok
}

public struct StationBundle: Codable {
	let code: Code?
	let name: String?
	let connectivity: Connectivity?
	let wsModel: WSModel?
	let gwModel: GWModel?
	let hwClass: String?

	enum CodingKeys: String, CodingKey {
		case code
		case name
		case connectivity
		case wsModel = "ws_model"
		case gwModel = "gw_model"
		case hwClass = "hw_class"
	}

	enum Code: String, Codable {
		case m5 = "M5"
		case h1 = "H1"
		case h2 = "H2"
		case d1 = "D1"
		case pulse = "PULSE"
	}

	enum WSModel: String, Codable {
		case ws1000 = "WS1000"
		case ws1001 = "WS1001"
		case ws2000 = "WS2000"
	}

	enum GWModel: String, Codable {
		case wg1000 = "WG1000"
		case wg1200 = "WG1200"
	}
}

public enum Connectivity: String, Codable {
	case wifi
	case helium
	case cellular
}

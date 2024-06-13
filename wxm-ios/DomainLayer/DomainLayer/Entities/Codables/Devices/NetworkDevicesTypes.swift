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

public enum DeviceRelation: String, Codable {
    case owned
    case followed
}

public enum BatteryState: String, Codable {
	case low
	case ok
}

public struct StationBundle: Codable {
	public let name: Code?
	public let title: String?
	public let connectivity: Connectivity?
	public let wsModel: WSModel?
	public let gwModel: GWModel?
	public let hwClass: String?

	enum CodingKeys: String, CodingKey {
		case name
		case title
		case connectivity
		case wsModel = "ws_model"
		case gwModel = "gw_model"
		case hwClass = "hw_class"
	}

	public enum Code: String, Codable {
		case m5
		case h1
		case h2
		case d1
		case pulse
	}

	public enum WSModel: String, Codable {
		case ws1000 = "WS1000"
		case ws1001 = "WS1001"
		case ws2000 = "WS2000"
	}

	public enum GWModel: String, Codable {
		case wg1000 = "WG1000"
		case wg1200 = "WG1200"
	}

	public init(name: Code?, title: String?, connectivity: Connectivity?, wsModel: WSModel?, gwModel: GWModel?, hwClass: String?) {
		self.name = name
		self.title = title
		self.connectivity = connectivity
		self.wsModel = wsModel
		self.gwModel = gwModel
		self.hwClass = hwClass
	}
}

public enum Connectivity: String, Codable {
	case wifi
	case helium
	case cellular
}

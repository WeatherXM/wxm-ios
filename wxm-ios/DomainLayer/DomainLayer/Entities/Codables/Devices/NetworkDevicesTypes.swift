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

public enum DeviceRelation: String, Codable, Sendable {
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
	public let wsModel: String?
	public let gwModel: String?
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

	public init(name: Code?, title: String?, connectivity: Connectivity?, wsModel: String?, gwModel: String?, hwClass: String?) {
		self.name = name
		self.title = title
		self.connectivity = connectivity
		self.wsModel = wsModel
		self.gwModel = gwModel
		self.hwClass = hwClass
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try? container.decodeIfPresent(StationBundle.Code.self, forKey: .name)
		self.title = try? container.decodeIfPresent(String.self, forKey: .title)
		self.connectivity = try? container.decodeIfPresent(Connectivity.self, forKey: .connectivity)
		self.wsModel = try? container.decodeIfPresent(String.self, forKey: .wsModel)
		self.gwModel = try? container.decodeIfPresent(String.self, forKey: .gwModel)
		self.hwClass = try? container.decodeIfPresent(String.self, forKey: .hwClass)
	}
}

public enum Connectivity: String, Codable {
	case wifi
	case helium
	case cellular
}

public enum PolStatus: String, Codable {
	case verified
	case notVerified = "LOCATION_NOT_VERIFIED"
	case noLocation = "NO_LOCATION_DATA"
}

public struct Metrics: Codable {
	public let ts: Date?
	public let qodScore: Int?
	public let polReason: PolStatus?

	enum CodingKeys: String, CodingKey {
		case ts
		case qodScore = "qod_score"
		case polReason = "pol_reason"
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.ts = try container.decodeIfPresent(Date.self, forKey: .ts)
		self.qodScore = try container.decodeIfPresent(Int.self, forKey: .qodScore)
		self.polReason = try? container.decodeIfPresent(PolStatus.self, forKey: .polReason) ?? .verified
	}
}

//
//  PublicHex.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

public struct PublicHex: Codable, Sendable, Equatable {
    public var index: String = ""
	public var capacity: Int?
    public var deviceCount: Int?
	public var activeDeviceCount: Int?
	public var averageDataQuality: Int?
    public var center: HexLocation = .init()
    public var polygon: [HexLocation] = []

    enum CodingKeys: String, CodingKey {
        case index
		case capacity
        case deviceCount = "device_count"
		case activeDeviceCount = "active_device_count"
		case averageDataQuality = "avg_data_quality"
        case center
        case polygon
    }

	init(index: String = "",
		 capacity: Int? = nil,
		 deviceCount: Int? = nil,
		 activeDeviceCount: Int? = nil,
		 averageDataQuality: Int? = nil,
		 center: HexLocation = .init(),
		 polygon: [HexLocation] = []) {
		self.index = index
		self.capacity = capacity
		self.deviceCount = deviceCount
		self.activeDeviceCount = activeDeviceCount
		self.averageDataQuality = averageDataQuality
		self.center = center
		self.polygon = polygon
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.index = try container.decode(String.self, forKey: .index)
		self.capacity = try container.decodeIfPresent(Int.self, forKey: .capacity)
		self.deviceCount = try container.decodeIfPresent(Int.self, forKey: .deviceCount)
		self.activeDeviceCount = try container.decodeIfPresent(Int.self, forKey: .activeDeviceCount)
		self.averageDataQuality = try? container.decodeIfPresent(Int.self, forKey: .averageDataQuality)
		self.center = try container.decode(HexLocation.self, forKey: .center)
		self.polygon = try container.decode([HexLocation].self, forKey: .polygon)
	}
}

public struct HexLocation: Codable, Sendable, Equatable {
    public var lat: Double = 0.0
    public var lon: Double = 0.0
}

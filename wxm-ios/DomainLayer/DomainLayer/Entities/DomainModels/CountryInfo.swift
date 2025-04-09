//
//  CountryInfo.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 17/10/23.
//

import Foundation
import CoreLocation

public struct CountryInfo: Decodable {
	public let code: String
	public let heliumFrequency: String?
	public var mapCenter: CLLocationCoordinate2D?

	enum CodingKeys: String, CodingKey {
		case code
		case heliumFrequency = "helium_frequency"
		case mapCenter = "map_center"
	}

	enum MapCenterCodingKeys: String, CodingKey {
		case lat
		case lon
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.code = try container.decode(String.self, forKey: .code)
		self.heliumFrequency = try container.decodeIfPresent(String.self, forKey: .heliumFrequency)

		if container.contains(.mapCenter) {
			let nestedContainer = try container.nestedContainer(keyedBy: MapCenterCodingKeys.self, forKey: .mapCenter)
			if let lat = try nestedContainer.decodeIfPresent(Double.self, forKey: .lat),
			   let lon = try nestedContainer.decodeIfPresent(Double.self, forKey: .lon) {
				self.mapCenter = CLLocationCoordinate2D(latitude: lat, longitude: lon)
			}
		}
	}

	public init(code: String, heliumFrequency: String? = nil, mapCenter: CLLocationCoordinate2D? = nil) {
		self.code = code
		self.heliumFrequency = heliumFrequency
		self.mapCenter = mapCenter
	}
}

//
//  NetworkSearchResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 21/6/23.
//

import Foundation

/// Constrained protocol for readability reasons.
/// `NetworkSearchDevice` and `NetworkSearchAddress` are conforming to this empty protocol just to be visible for the upper layers where the type casting will be performed
public protocol NetworkSearchItem {
    associatedtype Codable
}

extension NetworkSearchItem {
    public typealias Codable = Self
}

public struct NetworkSearchResponse: Codable, Sendable {
    public let devices: [NetworkSearchDevice]?
    public let addresses: [NetworkSearchAddress]?

	public init(devices: [NetworkSearchDevice]?, addresses: [NetworkSearchAddress]?) {
		self.devices = devices
		self.addresses = addresses
	}
}

public struct NetworkSearchDevice: Codable, NetworkSearchItem, Sendable {
    public let id: String?
    public let name: String?
    public let bundle: StationBundle?
    public let cellIndex: String?
    public let cellCenter: LocationCoordinates?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case bundle
        case cellIndex = "cell_index"
        case cellCenter = "cell_center"
    }

    public init(id: String?, name: String?, bundle: StationBundle?, cellIndex: String?, cellCenter: LocationCoordinates?) {
        self.id = id
        self.name = name
        self.bundle = bundle
        self.cellIndex = cellIndex
        self.cellCenter = cellCenter
    }
}

public struct NetworkSearchAddress: Codable, NetworkSearchItem, Sendable {
    public let name: String?
    public let place: String?
    public let center: LocationCoordinates?

    public init(name: String?, place: String?, center: LocationCoordinates?) {
        self.name = name
        self.place = place
        self.center = center
    }
}

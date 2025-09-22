//
//  NetworkDeviceSupportResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 22/9/25.
//

import Foundation

public struct NetworkDeviceSupportResponse: Sendable, Codable {
	public let status: Status?
	public let error: String?
	public let stationName: String?
	public let outputs: Outputs?

	enum CodingKeys: String, CodingKey {
		case status
		case error
		case stationName = "station_name"
		case outputs
	}

}

extension NetworkDeviceSupportResponse {
	public enum Status: String, Sendable, Codable {
		case succeeded
		case failed
	}

	public struct Outputs: Sendable, Codable {
		public let result: String?
	}
}

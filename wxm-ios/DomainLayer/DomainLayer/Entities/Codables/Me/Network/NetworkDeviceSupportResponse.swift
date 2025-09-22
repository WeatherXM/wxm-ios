//
//  NetworkDeviceSupportResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 22/9/25.
//

import Foundation

public struct NetworkDeviceSupportResponse: Sendable, Codable {
	let status: Status?
	let error: String?
	let stationName: String?
	let outputs: Outputs?

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
		let result: String?
	}
}

//
//  NetworkPostDevicePhotosResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 2/1/25.
//

import Foundation

public struct NetworkPostDevicePhotosResponse: Sendable, Codable {
	public let url: String?
	public let fields: [String: String]?

	public init(url: String?, fields: [String : String]?) {
		self.url = url
		self.fields = fields
	}
}

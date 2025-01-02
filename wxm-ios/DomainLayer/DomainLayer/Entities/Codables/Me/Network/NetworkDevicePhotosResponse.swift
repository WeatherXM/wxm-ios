//
//  NetworkDevicePhotosResponse.swift
//  DomainLayer
//
//  Created by Pantelis Giazitsis on 18/12/24.
//

import Foundation

public struct NetworkDevicePhotosResponse: Sendable {
	public let url: String?

	public init(url: String?) {
		self.url = url
	}
}

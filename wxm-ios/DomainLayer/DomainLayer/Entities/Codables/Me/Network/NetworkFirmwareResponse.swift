//
//  NetworkFirmwareResponse.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 18/5/22.
//

import Foundation

public struct NetworkFirmwareResponse: Codable, Sendable {
    public var id: EntityType = .init()
    public var createdTime: Int = 0
    public var additionalInfo: AdditionalInfo = .init()
    public var tenantId: EntityType = .init()
    public var deviceProfileId: EntityType = .init()
    public var type: String = ""
    public var title: String = ""
    public var version: String = ""
    public var tag: String = ""
    public var url: String? = ""
    public var hasData: Bool = false
    public var fileName: String = ""
    public var contentType: String = ""
    public var checksumAlgorithm: String = ""
    public var checksum: String = ""
    public var dataSize: Int = 0

	public init() {}
}

public struct EntityType: Codable, Sendable {
    public var entityType: String = ""
    public var id: String = ""
}

public struct AdditionalInfo: Codable, Sendable {
    public var description: String = ""
}

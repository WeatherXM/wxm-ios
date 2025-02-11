//
//  NetworkUserInfoResponse.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Foundation

public struct NetworkUserInfoResponse: Codable, Sendable {
    public var id: String? = ""
    public var email: String? = ""
    public var name: String? = ""
    public var firstName: String? = ""
    public var lastName: String? = ""
    public var wallet: Wallet?

    public init() {}
}

public struct Wallet: Codable, Sendable {
    public var address: String? = ""
    public var updatedAt: Int? = 0

    public init() {}
}

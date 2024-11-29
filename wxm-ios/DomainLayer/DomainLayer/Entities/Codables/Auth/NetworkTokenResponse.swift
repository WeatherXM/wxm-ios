//
//  NetworkTokenResponse.swift
//  DomainLayer
//
//  Created by Hristos Condrea on 17/5/22.
//

import Foundation
public struct NetworkTokenResponse: Codable, Sendable {
    public var token: String = ""
    public var refreshToken: String = ""

    enum CodingKeys: String, CodingKey {
        case token
        case refreshToken
    }

    public init() {}

    public init(token: String, refreshToken: String) {
        self.token = token
        self.refreshToken = refreshToken
    }
}

//
//  PublicHexError.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

import Foundation

public enum PublicHexError: Error, Sendable {
    case infrastructure
    case networkRelated(NetworkErrorResponse?)
    case serialization
}

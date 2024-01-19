//
//  PublicHexError.swift
//  DomainLayer
//
//  Created by Lampros Zouloumis on 17/8/22.
//

import Foundation

public enum PublicHexError: Error {
    case infrastructure
    case networkRelated(NetworkErrorResponse?)
    case serialization
}

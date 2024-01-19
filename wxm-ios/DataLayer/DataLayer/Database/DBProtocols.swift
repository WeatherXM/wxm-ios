//
//  DBProtocols.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 11/4/23.
//

import CoreData

protocol ManagedObjectToCodableConvertible {
    associatedtype Codable

    var toCodable: Codable? { get }
}

protocol CodableToManagedObjectConvertible {
    associatedtype NSManagedObject

    var toManagedObject: NSManagedObject? { get }
}

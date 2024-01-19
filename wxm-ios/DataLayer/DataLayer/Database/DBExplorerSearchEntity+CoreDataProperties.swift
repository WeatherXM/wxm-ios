//
//  DBExplorerSearchEntity+CoreDataProperties.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 29/6/23.
//
//

import Foundation
import CoreData


extension DBExplorerSearchEntity {

    @NSManaged public var timestamp: Date?
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var name: String?
}

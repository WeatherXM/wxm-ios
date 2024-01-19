//
//  DBExplorerAddress+CoreDataProperties.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 29/6/23.
//
//

import Foundation
import CoreData
import DomainLayer

extension DBExplorerAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBExplorerAddress> {
        return NSFetchRequest<DBExplorerAddress>(entityName: "DBExplorerAddress")
    }

    @NSManaged public var place: String?

}

extension DBExplorerAddress: ManagedObjectToCodableConvertible {
    var toCodable: NetworkSearchAddress? {
        NetworkSearchAddress(name: name,
                             place: place,
                             center: LocationCoordinates(lat: lat, long: lon))
    }
}

extension NetworkSearchAddress: CodableToManagedObjectConvertible {
    var toManagedObject: DBExplorerAddress? {
        let dbAddress = DBExplorerAddress(context: DatabaseService.shared.context)
        dbAddress.name = name
        dbAddress.lat = center?.lat ?? 0.0
        dbAddress.lon = center?.lon ?? 0.0
        dbAddress.place = place

        return dbAddress
    }
}

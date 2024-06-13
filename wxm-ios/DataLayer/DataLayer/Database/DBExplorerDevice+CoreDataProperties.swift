//
//  DBExplorerDevice+CoreDataProperties.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 29/6/23.
//
//

import Foundation
import CoreData
import DomainLayer

extension DBExplorerDevice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBExplorerDevice> {
        return NSFetchRequest<DBExplorerDevice>(entityName: "DBExplorerDevice")
    }

    @NSManaged public var id: String?
    @NSManaged public var cellIndex: String?
	@NSManaged public var bundle: DBBundle?
}

extension DBExplorerDevice: ManagedObjectToCodableConvertible {
    var toCodable: NetworkSearchDevice? {
        NetworkSearchDevice(id: id,
                            name: name,
							bundle: bundle?.toCodable,
                            cellIndex: cellIndex,
                            cellCenter: LocationCoordinates(lat: lat, long: lon))
    }
}

extension NetworkSearchDevice: CodableToManagedObjectConvertible {
    var toManagedObject: DBExplorerDevice? {
        let dbDevice = DBExplorerDevice(context: DatabaseService.shared.context)
        dbDevice.id = id
        dbDevice.cellIndex = cellIndex
		dbDevice.bundle = bundle?.toManagedObject
        dbDevice.name = name
        dbDevice.lat = cellCenter?.lat ?? 0.0
        dbDevice.lon = cellCenter?.lon ?? 0.0
        
        return dbDevice
    }
}

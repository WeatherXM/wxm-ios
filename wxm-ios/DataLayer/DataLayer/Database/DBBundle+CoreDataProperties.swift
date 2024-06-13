//
//  DBBundle+CoreDataProperties.swift
//  wxm-ios
//
//  Created by Pantelis Giazitsis on 13/6/24.
//
//

import Foundation
import CoreData
import DomainLayer

extension DBBundle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBBundle> {
        return NSFetchRequest<DBBundle>(entityName: "DBBundle")
    }

    @NSManaged public var name: String?
    @NSManaged public var title: String?
    @NSManaged public var connectivity: String?
    @NSManaged public var wsModel: String?
    @NSManaged public var gwModel: String?
    @NSManaged public var hwClass: String?
}

extension DBBundle: ManagedObjectToCodableConvertible {
	var toCodable: StationBundle? {
		guard let name,
			  let connectivity,
			  let wsModel,
			  let gwModel else {
			return nil
		}
		
		return StationBundle(name: StationBundle.Code(rawValue: name),
							 title: title,
							 connectivity: DomainLayer.Connectivity(rawValue: connectivity),
							 wsModel: StationBundle.WSModel(rawValue: wsModel),
							 gwModel: .init(rawValue: gwModel),
							 hwClass: hwClass)
	}
}

extension StationBundle: CodableToManagedObjectConvertible {
	var toManagedObject: DBBundle? {
		let dbBundle = DBBundle(context: DatabaseService.shared.context)
		dbBundle.name = name?.rawValue
		dbBundle.title = title
		dbBundle.connectivity = connectivity?.rawValue
		dbBundle.wsModel = wsModel?.rawValue
		dbBundle.gwModel = gwModel?.rawValue
		dbBundle.hwClass = hwClass

		return dbBundle
	}
}

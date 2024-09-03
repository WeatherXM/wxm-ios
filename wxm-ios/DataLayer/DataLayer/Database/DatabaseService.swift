//
//  DatabaseService.swift
//  DataLayer
//
//  Created by Pantelis Giazitsis on 11/4/23.
//

import CoreData

class DatabaseService {

    static let shared: DatabaseService = DatabaseService()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private var persistentContainer: NSPersistentContainer!

    private init() {
        persistentContainer = generatePersistentContainer()
    }
}

// MARK: - API

extension DatabaseService {

    func fetchWeatherFromDB(predicate: NSPredicate) -> [DBWeather] {
        let fetchRequest = DBWeather.fetchRequest()
        fetchRequest.predicate = predicate

        let dbEntities = fetch(request: fetchRequest)
        return dbEntities
    }

    func fetchExplorerDeviceFromDB(predicate: NSPredicate? = nil) -> [DBExplorerDevice] {
        let fetchRequest = DBExplorerDevice.fetchRequest()
        fetchRequest.predicate = predicate

        let dbEntities = fetch(request: fetchRequest)
        return dbEntities
    }

    func deleteExplorerDeviceFromDB(predicate: NSPredicate? = nil) {
        guard let fetchRequest = DBExplorerDevice.fetchRequest() as? NSFetchRequest<NSFetchRequestResult> else {
            return
        }
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
    }

    func fetchExplorerAddressFromDB(predicate: NSPredicate? = nil) -> [DBExplorerAddress] {
        let fetchRequest = DBExplorerAddress.fetchRequest()
        fetchRequest.predicate = predicate

        let dbEntities = fetch(request: fetchRequest)
        return dbEntities
    }

    func deleteExplorerAddressFromDB(predicate: NSPredicate? = nil) {
        guard let fetchRequest = DBExplorerAddress.fetchRequest() as? NSFetchRequest<NSFetchRequestResult> else {
            return
        }
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
    }

    func save<T>(object: T) where T: NSManagedObject {
        guard let context = object.managedObjectContext else { return }

        saveContext(context: context)
    }

    func delete<T>(object: T) where T: NSManagedObject {
        guard let context = object.managedObjectContext else { return }

        context.delete(object)
        saveContext(context: context)
    }
}

// MARK: - Core Data Saving support

private extension DatabaseService {

    func fetch<T>(request: NSFetchRequest<T>) -> [T] {
        do {
            let dbEntities = try context.fetch(request)
            return dbEntities
        } catch {
            print(error)
        }

        return []
    }

    func saveContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                #if DEBUG
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                #endif
            }
        }
    }

    func generatePersistentContainer() -> NSPersistentContainer {
        guard let url = Bundle(for: type(of: self)).url(forResource: "Model", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Could not load model")
        }

        let container = NSPersistentContainer(name: "Model", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        return container
    }
}

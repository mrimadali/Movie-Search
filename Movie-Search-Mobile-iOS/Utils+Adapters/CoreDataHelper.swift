//
//  CoreDataHelper.swift
//  Movie-Search-Mobile-iOS
//
//  Created by Imad on 4/20/18.
//  Copyright © 2018 Imad. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
    
    // An object that describes a schema—a collection of entities (data models) that you use in your application.
    class func managedObjectModel() -> NSManagedObjectModel {
        let modelUrl = Bundle.main.url(forResource: "Movie_Search_Mobile_iOS", withExtension: "momd")
        let mom = NSManagedObjectModel(contentsOf: modelUrl!)
        return mom!
    }
    
    // An object representing the location of a resource that bridges to URL; use NSURL when you need reference semantics or other Foundation-specific behavior.
    class func applicationCachesDirectory()->NSURL {
        let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        
        return NSURL(fileURLWithPath: documentDirectories.first!, isDirectory: false)
    }

    // A coordinator that associates persistent stores with a model (or a configuration of a model) and that mediates between the persistent stores and the managed object contexts.

    class func persistentStoreCoordinator() -> NSPersistentStoreCoordinator {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: CoreDataHelper.managedObjectModel())
        let storeURL = CoreDataHelper.applicationCachesDirectory().appendingPathComponent("MovieSearchQueries.sqlite")
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        }
        catch {
            let failureReason = "There was an error creating or loading the application's saved data."

            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)

            print("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return persistentStoreCoordinator

    }
    
    // An object representing a single object space or scratch pad that you use to fetch, create, and save managed objects.

    class func managedObjectContext() -> NSManagedObjectContext {
        let coordinator = CoreDataHelper.persistentStoreCoordinator()
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }
    
    // Creates, configures, and returns an instance of the class for the entity with a given name
    class func insertManagedObject(className:String, managedObjectContext:NSManagedObjectContext) -> AnyObject {
        
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: className, into: managedObjectContext) as NSManagedObject
        
        return managedObject
    }
    
    // Attempts to commit unsaved changes to registered objects to the context’s parent store.

    class func saveManagedObjectContext(managedObjectContext:NSManagedObjectContext) {
        do {
            try managedObjectContext.save()
        }catch let error as NSError  {
            print("Could not save \(error)")
        }
    }
    
    // Returns an array of objects that meet the criteria specified by a given fetch request.

    class func fetchEntities(className:String, predicate:NSPredicate?, sortDesc:NSSortDescriptor?,managedObjectContext:NSManagedObjectContext) -> NSArray {
        let entityDescription = NSEntityDescription.entity(forEntityName: className, in: managedObjectContext)
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        request.entity = entityDescription
        if predicate != nil {
            request.predicate = predicate
        }
        if sortDesc != nil {
            request.sortDescriptors = [sortDesc!]
        }
        request.returnsObjectsAsFaults = false
        do {
            let results = try managedObjectContext.fetch(request)
            // success ...
            return results as NSArray
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        return []
    }
    
    // Specifies an object that should be removed from its persistent store when changes are committed.

    class func deleteLastItem(className: String, managedObjectContext: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entity(forEntityName: className, in: managedObjectContext)
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        request.entity = entityDescription
        do {
            let results = try managedObjectContext.fetch(request)
            managedObjectContext.delete(results.first as! NSManagedObject)
            CoreDataHelper.saveManagedObjectContext(managedObjectContext: managedObjectContext)
            
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
}

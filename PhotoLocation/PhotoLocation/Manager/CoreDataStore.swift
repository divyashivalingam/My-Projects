//
//  CoreDataStore.swift
//  PhotoLocation
//
//  Copyright © 2018 divya. All rights reserved.
//

import Foundation
import CoreData

@objc open class CoreDataStore: NSObject {
    
    open var entityName: String
    
    init(entityName: String) {
        self.entityName = entityName
        super.init();
    }
    
    var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "LocationData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Error in getting persistent container \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    open func saveContext () {
        let context = self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Error in saving context \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    open func getEntityDescrption() -> NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: self.entityName , in: self.persistentContainer.viewContext)!
    }
    
    open func getManagedObject () -> NSManagedObject{
        let entity = self.getEntityDescrption()
        return NSManagedObject(entity: entity, insertInto: self.persistentContainer.viewContext)
    }
}

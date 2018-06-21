//
//  CoreDataManager.swift
//  PhotoLocation
//
//  Copyright © 2018 divya. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

@objc open class CoreDataManager: NSObject {
    
    @objc static let coreDataSharedInstance = CoreDataStore(entityName: "LocationByUser")
    
    public override init() {
        super.init();
    }
    
    static let managedObject : NSManagedObject = {
        return coreDataSharedInstance.getManagedObject()
    }()
    
    static let managedObjectContext : NSManagedObjectContext = {
        return coreDataSharedInstance.persistentContainer.viewContext
    }()
    
    class func saveData() -> Bool{
        var saveSuccess : Bool = false
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                saveSuccess = true
            } catch {
                let nserror = error as NSError
                print("CoreData Err:Failed saving \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
        
        return saveSuccess

    }
   
    class func fetchAllData()-> AnyObject{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataSharedInstance.entityName)
        request.returnsObjectsAsFaults = false
      
        do {
            return try managedObjectContext.fetch(request) as AnyObject
        } catch {
            print("Core data error ..Fetch failed")
        }
        
        return "" as AnyObject
    }
    
    class func fetchResultsBy(query : String, string: String) -> AnyObject {
        let predicate:NSPredicate = NSPredicate(format: "locationName == %@", string)
        let entity = NSEntityDescription.entity(forEntityName: coreDataSharedInstance.entityName, in: managedObjectContext)

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: (entity?.name)!)
        request.returnsObjectsAsFaults = false
        request.predicate = predicate

        do {
            return try managedObjectContext.fetch(request) as AnyObject
            
        }catch {
            print("CoreData Err:Fetch error")
        }
        
        return "" as AnyObject
    }
}


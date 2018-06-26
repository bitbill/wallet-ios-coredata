//
//  ModelManager.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/25.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit
import CoreData
var g_persistentStoreCoordinator : NSPersistentStoreCoordinator!

class ModelManager: NSObject, Procedure {
    
    open static let sharedManager = ModelManager.init(main:true)
    var context: Context!
    
    public func removeStore() throws {
        try FileManager.default.removeItem(at: URL(fileURLWithPath:ModelManager.sqliteFilePath()) as URL)
        _ = try? FileManager.default.removeItem(atPath: "\(ModelManager.sqliteFilePath())-shm")
        _ = try? FileManager.default.removeItem(atPath: "\(ModelManager.sqliteFilePath())-wal")
        
    }
    
    func perform(_ operation: @escaping (_ context: Context, _ save: @escaping () -> Void) -> (), completion: @escaping (Error?) -> ()) {
        let context: NSManagedObjectContext = self.context as! NSManagedObjectContext
        var _error: Error!
        context.perform {
            operation(context, { () -> Void in
                do {
                    try context.save()
                }
                catch {
                    _error = error
                }
                if let _ = context.parent {
                    let m : NSManagedObjectContext = context.parent!
                    m.perform {
                        if m.hasChanges {
                            do {
                                try m.save()
                            }
                            catch {
                                _error = error
                            }
                        }
                        completion(_error)
                    }
                
                } else {
                    completion(_error)
                }
            })
        }
    }
    
    public func performAndWait<T>(_ operation: @escaping (_ context: Context, _ save: @escaping () -> Void) throws -> T) throws -> T  {
        let context: NSManagedObjectContext = self.context as! NSManagedObjectContext
        var _error: Error!
        
        var returnedObject: T!
        context.performAndWait {
            do {
                returnedObject = try operation(context, { () -> Void in
                    do {
                        try context.save()
                    }
                    catch {
                        _error = error
                    }
                    if let _ = context.parent {
                        let m : NSManagedObjectContext = context.parent!
                        m.performAndWait({
                            if m.hasChanges {
                                do {
                                    try m.save()
                                }
                                catch {
                                    _error = error
                                }
                            }
                        })
                    }
                })
            } catch {
                _error = error
            }
        }
        if let error = _error {
            throw error
        }
        
        return returnedObject
    }

    //MARK: handler
    // Insert a new NSManagedObject, it's all property is nil
    open func insertNew(_ entityName: String) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: self.context as! NSManagedObjectContext)
    }
    
    open func refresh(_ object: NSManagedObject, mergeChanges flag: Bool) {
        let c = self.context as! NSManagedObjectContext
        c.refresh(object, mergeChanges: flag)
    }
    
    // NSManagedObjectContext do save
    open func save() {
        let c = self.context as! NSManagedObjectContext
        try? c.save()
    }
    
    open func delete(_ object: NSManagedObject) {
        let c = self.context as! NSManagedObjectContext
        c.delete(object)
    }

    //MARK: init
    
    public init(main : Bool) {
        let mainContext : NSManagedObjectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        let coordinator = ModelManager.persistentStoreCoordinator()
        mainContext.persistentStoreCoordinator = coordinator
        mainContext.undoManager = nil;
        let policy : NSMergePolicy = NSMergePolicy.init(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
        mainContext.mergePolicy = policy
        self.context = mainContext
    }
    
    public override init() {
        let privateContext : NSManagedObjectContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = ModelManager.sharedManager.context as? NSManagedObjectContext
        self.context = privateContext
    }
    
    open class func managedObjectModel() -> NSManagedObjectModel {
        let bundlePath : String = Bundle.main.bundlePath
        let modelFolder : String = bundlePath + "/CoreDataDemo.momd"
        var modelFile : String = modelFolder + "/CoreDataDemo.mom"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: modelFile) {
            modelFile = bundlePath + "/CoreDataDemo.mom"
            if !fileManager.fileExists(atPath: modelFile) {
                assertionFailure("I can not find model file");
            }
        }
        let managedObjectModel : NSManagedObjectModel = NSManagedObjectModel.init(contentsOf: NSURL.fileURL(withPath: modelFile))!
        return managedObjectModel
    }
    
    open class func persistentStoreCoordinator() -> NSPersistentStoreCoordinator {
        if g_persistentStoreCoordinator == nil {
            g_persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: self.managedObjectModel())
            let options = [NSInferMappingModelAutomaticallyOption : true, NSMigratePersistentStoresAutomaticallyOption : true]
            do {
                try g_persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URL.init(fileURLWithPath: self.sqliteFilePath()) , options: options)
            } catch {
                print(error)
                print(error.localizedDescription)
                let fm = FileManager.default
                if fm.fileExists(atPath: self.sqliteFilePath()) {
                    try? fm.removeItem(atPath: self.sqliteFilePath())
                }
            }
        }
        return g_persistentStoreCoordinator;
    }
    
    
    
    class func sqliteFilePath() -> String {
        let libraryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return libraryPath + "CoreDatafv.sqlite"
        
    }
}

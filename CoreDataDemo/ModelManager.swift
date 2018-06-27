//
//  ModelManager.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/25.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit
import CoreData

class ModelManager: NSObject, Procedure {
    
    func removeStore() throws {
        
    }
    open static let sharedManager = ModelManager(main:true)
    var container : NSPersistentContainer =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    var context: Context!
    
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
    
    init(main : Bool) {
        if main {
            self.context = self.container.viewContext
        } else {
            let privateContext : NSManagedObjectContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = self.container.viewContext
            self.context = privateContext
        }
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
}

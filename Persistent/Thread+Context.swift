//
//  Thread.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/29.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit
import CoreData

var contextKey = "contextKey"

extension Thread {
    
    open var context: NSManagedObjectContext? {
        get {
            guard let ct = objc_getAssociatedObject(self, &contextKey) as? NSManagedObjectContext else { return nil }
            return ct
        }
    }
    
    open func bindContext(_ context : NSManagedObjectContext) {
        objc_setAssociatedObject(self, &contextKey, context, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
    
    open func removeContext() {
        guard let c = self.context else { return }
        objc_removeAssociatedObjects(c)
    }
}

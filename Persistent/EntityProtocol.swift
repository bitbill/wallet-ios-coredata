//
//  ModelObject.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/25.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit
import CoreData
public protocol EntityProtocol {
    
}

extension NSManagedObject: EntityProtocol {}

extension NSManagedObject {
    
    open class var entityName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
}

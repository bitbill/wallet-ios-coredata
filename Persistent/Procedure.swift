//
//  Manager.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/25.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit

public protocol Procedure {
    var context: Context! { get }
    func removeStore() throws
    
    @available(iOS 5.0, *)
    func perform(_ operation: @escaping (_ context: Context, _ save: @escaping () -> Void) -> (), completion: @escaping (Error?) -> ())
    
    
    /* synchronously performs the block on the context's queue.  May safely be called reentrantly.  */
    @available(iOS 5.0, *)
    func performAndWait<T>(_ operation: @escaping (_ context: Context, _ save: @escaping () -> Void) throws -> T) throws -> T
    
}


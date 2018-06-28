//
//  Context.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/26.
//  Copyright © 2018 BitBill. All rights reserved.
//

import Foundation
import CoreData

public protocol ContextProtocol {
    func fetch<T: EntityProtocol>(_ fetchRequest: FetchRequestProtocol) throws -> [T]
    func insert<T: EntityProtocol>(_ entity: T) throws
    func new<T: EntityProtocol>() throws -> T
    func create<T: EntityProtocol>() throws -> T
    func remove<T: EntityProtocol>(_ objects: [T]) throws
    func remove<T: EntityProtocol>(_ object: T) throws
    func removeAll() throws
}


// MARK: - Extension of Context implementing convenience methods.

public extension ContextProtocol {
    
    public func create<T: EntityProtocol>() throws -> T {
        let instance: T = try self.new()
        try self.insert(instance)
        return instance
    }
    
    public func remove<T: EntityProtocol>(_ object: T) throws {
        return try self.remove([object])
    }
    
}

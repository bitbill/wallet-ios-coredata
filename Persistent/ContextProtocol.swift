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
    func fetchModel<T: EntityProtocol>(_ fetchRequest: FetchRequestProtocol) -> [T]
    func newModel<T: EntityProtocol>() throws -> T
    func remove<T: EntityProtocol>(_ objects: [T]) throws
    func remove<T: EntityProtocol>(_ object: T) throws
    func removeAll() throws
}

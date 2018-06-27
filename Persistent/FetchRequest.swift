//
//  FetchRequest.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/25.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit
import CoreData
public protocol FetchRequest {
    
    func filtered(with predicate: NSPredicate) -> FetchRequest
    
    func filtered(with key: String, equalTo value: String) -> FetchRequest
    
    func filtered(with key: String, in value: [String]) -> FetchRequest
    
    func filtered(with key: String, notIn value: [String]) -> FetchRequest
    
    func filtered(with key: String, contains value: [String]) -> FetchRequest
    
    func sorted(with sortDescriptor: NSSortDescriptor) -> FetchRequest
    
    func sorted(with key: String?, ascending: Bool, comparator cmptr: @escaping Comparator) -> FetchRequest
    
    func sorted(with key: String?, ascending: Bool) -> FetchRequest
    
    func sorted(with key: String?, ascending: Bool, selector: Selector) -> FetchRequest
    
    func request(withPredicate predicate: NSPredicate) -> FetchRequest
    
    func request(withSortDescriptor sortDescriptor: NSSortDescriptor) -> FetchRequest
}


//extension NSFetchRequest : FetchRequest {
public extension FetchRequest where Self:NSFetchRequest<NSFetchRequestResult> {
    // MARK: - Public Builder Methods
    
    public func filtered(with predicate: NSPredicate) -> FetchRequest {
        return self
            .request(withPredicate: predicate)
    }
    
    public func filtered(with key: String, equalTo value: String) -> FetchRequest {
        return self
            .request(withPredicate: NSPredicate(format: "\(key) == %@", value))
    }
    
    public func filtered(with key: String, in value: [String]) -> FetchRequest {
        return self
            .request(withPredicate: NSPredicate(format: "\(key) IN %@", value))
    }
    
    public func filtered(with key: String, notIn value: [String]) -> FetchRequest {
        return self
            .request(withPredicate: NSPredicate(format: "NOT (\(key) IN %@)", value))
    }
    
    func filtered(with key: String, contains value: [String]) -> FetchRequest {
        return self
            .request(withPredicate: NSPredicate(format: "\(key) CONTAINS[c] %@", value))
    }
    
    public func sorted(with sortDescriptor: NSSortDescriptor) -> FetchRequest {
        return self
            .request(withSortDescriptor: sortDescriptor)
    }
    
    public func sorted(with key: String?, ascending: Bool, comparator cmptr: @escaping Comparator) -> FetchRequest {
        return self
            .request(withSortDescriptor: NSSortDescriptor(key: key, ascending: ascending, comparator: cmptr))
    }
    
    public func sorted(with key: String?, ascending: Bool) -> FetchRequest {
        return self
            .request(withSortDescriptor: NSSortDescriptor(key: key, ascending: ascending))
    }
    
    public func sorted(with key: String?, ascending: Bool, selector: Selector) -> FetchRequest {
        return self
            .request(withSortDescriptor: NSSortDescriptor(key: key, ascending: ascending, selector: selector))
    }
    
    func request(withPredicate predicate: NSPredicate) -> FetchRequest {
        self.predicate = predicate
        return self
    }
    
    func request(withSortDescriptor sortDescriptor: NSSortDescriptor) -> FetchRequest {
        self.sortDescriptors = [sortDescriptor]
        return self
    }
}





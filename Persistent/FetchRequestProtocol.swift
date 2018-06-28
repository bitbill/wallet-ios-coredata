//
//  FetchRequest.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/25.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit
import CoreData
public protocol FetchRequestProtocol {
    
    func filtered(with predicate: NSPredicate) -> FetchRequestProtocol
    
    func filtered(with key: String, equalTo value: String) -> FetchRequestProtocol
    
    func filtered(with key: String, in value: [String]) -> FetchRequestProtocol
    
    func filtered(with key: String, notIn value: [String]) -> FetchRequestProtocol
    
    func filtered(with key: String, contains value: [String]) -> FetchRequestProtocol
    
    func sorted(with sortDescriptor: NSSortDescriptor) -> FetchRequestProtocol
    
    func sorted(with key: String?, ascending: Bool, comparator cmptr: @escaping Comparator) -> FetchRequestProtocol
    
    func sorted(with key: String?, ascending: Bool) -> FetchRequestProtocol
    
    func sorted(with key: String?, ascending: Bool, selector: Selector) -> FetchRequestProtocol
    
    func request(withPredicate predicate: NSPredicate) -> FetchRequestProtocol
    
    func request(withSortDescriptor sortDescriptor: NSSortDescriptor) -> FetchRequestProtocol
}


//extension NSFetchRequest : FetchRequest {
public extension FetchRequestProtocol where Self:NSFetchRequest<NSFetchRequestResult> {
    // MARK: - Public Builder Methods
    
    public func filtered(with predicate: NSPredicate) -> FetchRequestProtocol {
        return self
            .request(withPredicate: predicate)
    }
    
    public func filtered(with key: String, equalTo value: String) -> FetchRequestProtocol {
        return self
            .request(withPredicate: NSPredicate(format: "\(key) == %@", value))
    }
    
    public func filtered(with key: String, in value: [String]) -> FetchRequestProtocol {
        return self
            .request(withPredicate: NSPredicate(format: "\(key) IN %@", value))
    }
    
    public func filtered(with key: String, notIn value: [String]) -> FetchRequestProtocol {
        return self
            .request(withPredicate: NSPredicate(format: "NOT (\(key) IN %@)", value))
    }
    
    func filtered(with key: String, contains value: [String]) -> FetchRequestProtocol {
        return self
            .request(withPredicate: NSPredicate(format: "\(key) CONTAINS[c] %@", value))
    }
    
    public func sorted(with sortDescriptor: NSSortDescriptor) -> FetchRequestProtocol {
        return self
            .request(withSortDescriptor: sortDescriptor)
    }
    
    public func sorted(with key: String?, ascending: Bool, comparator cmptr: @escaping Comparator) -> FetchRequestProtocol {
        return self
            .request(withSortDescriptor: NSSortDescriptor(key: key, ascending: ascending, comparator: cmptr))
    }
    
    public func sorted(with key: String?, ascending: Bool) -> FetchRequestProtocol {
        return self
            .request(withSortDescriptor: NSSortDescriptor(key: key, ascending: ascending))
    }
    
    public func sorted(with key: String?, ascending: Bool, selector: Selector) -> FetchRequestProtocol {
        return self
            .request(withSortDescriptor: NSSortDescriptor(key: key, ascending: ascending, selector: selector))
    }
    
    func request(withPredicate predicate: NSPredicate) -> FetchRequestProtocol {
        self.predicate = predicate
        return self
    }
    
    func request(withSortDescriptor sortDescriptor: NSSortDescriptor) -> FetchRequestProtocol {
        self.sortDescriptors = [sortDescriptor]
        return self
    }
}





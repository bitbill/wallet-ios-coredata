//
//  BILContactManager.swift
//  wallet-ios-core
//
//  Created by 仇弘扬 on 2017/12/26.
//  Copyright © 2017年 BitBill. All rights reserved.
//

import Foundation
import UIKit
import CoreData


extension Notification.Name {
    
    static let contactDidChanged = Notification.Name("contactDidChanged")
    static let transactionDidChanged = Notification.Name("contactDidChanged")
    static let coinDidAdded = Notification.Name("contactDidChanged")
}

let bil_contactManager = BILCoreDataModelManager<ContactModel>(notificationName: .contactDidChanged)
let bil_btc_wallet_addressManager = BILCoreDataModelManager<BTCWalletAddressModel>(notificationName: nil)
let bil_btc_tx_addressManager = BILCoreDataModelManager<BTCTXAddressModel>(notificationName: nil)
let bil_btc_transactionManager = BILCoreDataModelManager<BTCTransactionModel>(notificationName: .transactionDidChanged)
let bil_transactionManager = BILCoreDataModelManager<TransactionModel>(notificationName: .transactionDidChanged)
let bil_btc_walletManager = BILCoreDataModelManager<BitcoinWalletModel>(notificationName: nil)
let bil_eth_walletManager = BILCoreDataModelManager<EthereumWalletModel>(notificationName: nil)
let bil_coin_manager = BILCoreDataModelManager<CoinModel>(notificationName: .coinDidAdded)
let bil_eth_coinManager = BILCoreDataModelManager<ETHCoinModel>(notificationName: .coinDidAdded)
let bil_erc20Token_Manager = BILCoreDataModelManager<ERC20Token>(notificationName: nil)
let bil_eth_transactionManager = BILCoreDataModelManager<ETHTransactionModel>(notificationName: .transactionDidChanged)
let bil_eos_mappingManager = BILCoreDataModelManager<EOSMappingModel>(notificationName: nil)

let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

extension Thread {
    open var context : NSManagedObjectContext? {
        get {
            if self.isMainThread {
                return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                return privateContext
            }
        }
    }
}


class BILCoreDataModelManager<T: NSManagedObject>: NSObject, ModelManagerProtocol{
    
    
    var mainContext: ContextProtocol!
    var context: ContextProtocol!
    
    var notificationName: Notification.Name?
    
    convenience init(notificationName: Notification.Name? = nil) {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        self.init(notificationName:notificationName, container:container)
    }
    
    init(notificationName: Notification.Name? = nil, container:NSPersistentContainer) {
        self.notificationName = notificationName
        self.mainContext = container.viewContext
        if privateContext.parent == nil {
            privateContext.parent = self.mainContext as? NSManagedObjectContext
        }
        
        self.context = privateContext
    }
    
    
    
    var models: [T] {
        get {
            var results = [T]()
            let c : NSManagedObjectContext = self.mainContext as! NSManagedObjectContext
            let result : [T] = c.fetchModel(BILFetchRequest())
            results.append(contentsOf: result)
            return results
        }
    }
    
    func removeStore() throws {
        
    }
    
    func postNotification() {
        guard let n = notificationName else { return }
        NotificationCenter.default.post(name: n, object: nil)
    }
    
    open func performAsync(_ block: @escaping () -> Swift.Void, completion: @escaping (Error?) -> ()) {
        let context: NSManagedObjectContext = self.context as! NSManagedObjectContext
        var _error: Error!
        context.perform {
            block()
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
                            self.postNotification()
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
        }
    }
    
    
    open func performSync(_ block: () -> Swift.Void) throws {
        let context: NSManagedObjectContext = self.mainContext as! NSManagedObjectContext
        var _error: Error!
        context.performAndWait {
            block()
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
                            self.postNotification()
                        }
                        catch {
                            _error = error
                        }
                    }
                })
            }
        }
        if let error = _error {
            throw error
        }
    }
    
    public func newModel<T: EntityProtocol>() -> T {
        let ct : NSManagedObjectContext = context as! NSManagedObjectContext
        return ct.newModel()
    }
    
    func newModelIfNeeded(key: String, value: String) -> T {
        guard let model = fetch(key: key, value: value) else
        {
            return newModel()
            
        }
        return model
    }
    
    enum BILCoreDataQueryPolicy {
        case match
        case containIgnoreCase
        
        var connector: String {
            switch self {
            case .match:
                return "="
            case .containIgnoreCase:
                return "CONTAINS[c]"
            }
        }
    }
    
    func newModelIfNeeded(keyValues: (key: String, value: String)... , policy: BILCoreDataQueryPolicy = .match) -> T {
        guard let model = fetch(keyValues: keyValues, policy: policy) else { return newModel() }
        return model
    }
    
    func fetch(key: String, value: String, policy: BILCoreDataQueryPolicy = .match) -> T? {
        return fetch(keyValues: (key, value), policy: policy)
    }
    
    func fetch(keyValues: [(key: String, value: String)], policy: BILCoreDataQueryPolicy = .match) -> T? {
        return fetchAll(keyValues: keyValues, policy: policy).first
    }
    
    func fetchAll(keyValues: [(key: String, value: String)], policy: BILCoreDataQueryPolicy = .match) -> [T] {
        var arr = [String]()
        for (key, value) in keyValues {
            arr.append("\(key) \(policy.connector) '\(value)'")
        }
        let str = arr.joined(separator: " AND ")
        guard let ct = Thread.current.context else { return [] }
        let results : [T] = ct.fetchModel(BILFetchRequest().filtered(with: NSPredicate(format: "\(str)")))
        return results
    }
    
    func fetch(keyValues: (key: String, value: String)..., policy: BILCoreDataQueryPolicy = .match) -> T? {
        return fetch(keyValues: keyValues, policy: policy)
    }
    
    func fetchCount(key: String, value: String) -> Int {
        let count = 0
        do {
            let request: NSFetchRequest = NSFetchRequest<T>(entityName:T.self.entityName)
            request.predicate = NSPredicate(format: "\(key)=%@", value)
            guard let ct : NSManagedObjectContext = Thread.current.context else { return 0}
            let count = try ct.count(for: request)
            if count == NSNotFound {
                return 0
            }
            return count
        } catch {
            return count
        }
    }
    
    func saveModels() throws {
        guard let ct : NSManagedObjectContext = Thread.current.context else { return }
        guard ct.hasChanges else {
            return
        }
        try ct.save()
    }
    
    func remove(model: T, context : ContextProtocol? = nil) throws {
        guard let ct : NSManagedObjectContext = Thread.current.context else { return }
        ct.delete(model)
        try ct.save()
        postNotification()
    }
    
    func remove(models: [T], context : ContextProtocol? = nil) throws {
        guard let ct : NSManagedObjectContext = Thread.current.context else { return }
        for model in models {
            ct.delete(model)
        }
        try ct.save()
        postNotification()
    }
    
}

//
//  Manager.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/25.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit

public protocol ModelManagerProtocol {
    
    func performAsync(_ block: @escaping () -> Swift.Void, completion: @escaping (Error?) -> ())
    
    func performSync(_ block: () -> Swift.Void) throws
    
}


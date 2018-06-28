//
//  BILFetchRequest.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/27.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit
import CoreData

open class BILFetchRequest : NSFetchRequest<NSFetchRequestResult> {}

extension BILFetchRequest : FetchRequestProtocol {}

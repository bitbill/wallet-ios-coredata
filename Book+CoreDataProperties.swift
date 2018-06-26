//
//  Book+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/19.
//  Copyright © 2018 BitBill. All rights reserved.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var bookId: Int32
    @NSManaged public var bookName: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var author: Author?

}

//
//  BitRecordDemoTests.swift
//  BitRecordDemoTests
//
//  Created by BitBill on 2018/6/28.
//  Copyright © 2018 BitBill. All rights reserved.
//

import XCTest
import CoreData

@testable import CoreDataDemo

var schoolManager : BILCoreDataModelManager<School>!
var teacherManager : BILCoreDataModelManager<Teacher>!
var studentManager : BILCoreDataModelManager<Student>!
class CoreDataDemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        testPrepareEnvironment()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: CoreDataDemoTests.classForCoder())
        let modelFolder = bundle.bundlePath + "/Model.momd"
        var modelFile = modelFolder + "/Model.mom"
        if !FileManager.default.fileExists(atPath: modelFile) {
            modelFile = modelFolder + "/Model.mom"
            if !FileManager.default.fileExists(atPath: modelFile) {
                fatalError("Cannot find model file")
            }
        }
        let model : NSManagedObjectModel = NSManagedObjectModel(contentsOf: URL(fileURLWithPath: modelFile))!
        let container = NSPersistentContainer(name: "Model", managedObjectModel:model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        Thread.current.bindContext(container.viewContext)
        return container
    }()
    
    
    
    
    func testPrepareEnvironment() {
        _ = self.persistentContainer
        schoolManager = BILCoreDataModelManager<School>(notificationName: .contactDidChanged, container: self.persistentContainer)
        teacherManager = BILCoreDataModelManager<Teacher>(notificationName: .contactDidChanged, container: self.persistentContainer)
        studentManager = BILCoreDataModelManager<Student>(notificationName: .contactDidChanged, container: self.persistentContainer)
        XCTAssertNotNil(self.persistentContainer.persistentStoreCoordinator)
        XCTAssertNotNil(self.persistentContainer.persistentStoreDescriptions)
        XCTAssertNotNil(schoolManager)
        XCTAssertNotNil(teacherManager)
        XCTAssertNotNil(studentManager)
    }
    
    func testInsertSchool() {
        let expectation = XCTestExpectation(description: "testInsertSchool")
        schoolManager.performAsync({
            let schoolNumber = 5
            let school : School? = schoolManager.newModelIfNeeded(key: "number", value: "5")
            school?.name = "第一高级中学"
            school?.address = "上海杨浦"
            school?.number = Int32(schoolNumber)
        }) { (error) in
            XCTAssertNil(error)
            let results : [School]? = self.fetch(fetchRequest: BILFetchRequest().filtered(with: "number", equalTo: "5"), manager: schoolManager)
            XCTAssertTrue(results?.count == 1)
            expectation.fulfill()
        }
        wait(for:[expectation], timeout: 10)
    }
    
    func testInsertSame() {
        let expectation = XCTestExpectation(description: "testInsertSame")
        schoolManager.performAsync({
            for _ in 0...10 {
                do {
                    let schoolNumber = 5
                    var school : School? = schoolManager.fetch(key: "number", value: "5")
                    if school == nil {
                        school = schoolManager.newModel()
                    }
                    school?.name = "第一高级中学"
                    school?.address = "上海杨浦"
                    school?.number = Int32(schoolNumber)
                } catch {
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                }
            }
        }) { (error) in
            XCTAssertNil(error)
            let results : [School]? = self.fetch(fetchRequest: BILFetchRequest(entityName: "School").filtered(with: "number", equalTo: "5"), manager: schoolManager)
            XCTAssertTrue(results?.count == 1)
            expectation.fulfill()
        }
        wait(for:[expectation], timeout: 10)
    }
    
    func testRemove() {
        let expectation = XCTestExpectation(description: "testRemove")
        schoolManager.performAsync({
            do {
                let school : School? = schoolManager.fetch(key: "number", value: "5")
                if school != nil {
                    try schoolManager.remove(model: school!)
                }
            } catch {
                XCTAssertNil(error)
            }
            
        }) { (error) in
            XCTAssertNil(error)
            let results : [School]? = self.fetch(fetchRequest: BILFetchRequest(entityName: "School").filtered(with: "number", equalTo: "5"), manager: schoolManager)
            XCTAssertTrue(results?.count == 0)
            expectation.fulfill()
        }
        wait(for:[expectation], timeout: 10)
    }
    
    func testRemoveAll() {
        
    }
    
    func fetch<T>(fetchRequest: FetchRequestProtocol, manager: BILCoreDataModelManager<T>) -> [T]? {
        let results : [T]? = manager.mainContext.fetchModel(fetchRequest)
        return results
    }
    
    
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

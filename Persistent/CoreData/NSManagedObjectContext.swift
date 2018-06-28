import Foundation
import CoreData

public indirect enum StorageError: Error {
    
    case writeError
    case invalidType
    case fetchError(Error)
    case store(Error)
    case invalidOperation(String)
    case unknown
    
}
// MARK: - NSManagedObjectContext Extension (Context)

extension NSManagedObjectContext: ContextProtocol {
    
    public func fetch<T>(_ fetchRequest: FetchRequestProtocol) throws -> [T] where T : EntityProtocol {
        guard let entity = T.self as? NSManagedObject.Type else { throw StorageError.invalidType }
        let request : BILFetchRequest = fetchRequest as! BILFetchRequest
        request.entity = NSEntityDescription.entity(forEntityName: entity.entityName, in: self)
        let results = try self.fetch(request)
        let typedResults = results.map {$0 as! T}
        return typedResults
    }
    
    public func insert<T: EntityProtocol>(_ entity: T) throws {}
    
    public func new<T: EntityProtocol>() throws -> T {
        guard let entity = T.self as? NSManagedObject.Type else { throw StorageError.invalidType }
        let object = NSEntityDescription.insertNewObject(forEntityName: entity.entityName, into: self)
        if let inserted = object as? T {
            return inserted
        }
        else {
            throw StorageError.invalidType
        }
    }
    
    public func remove<T: EntityProtocol>(_ objects: [T]) throws {
        for object in objects {
            guard let object = object as? NSManagedObject else { continue }
            self.delete(object)
        }
    }
    
    public func remove<T: EntityProtocol>(_ object: T) throws {
        guard let object = object as? NSManagedObject else { return }
        self.delete(object)
    }
    
    public func removeAll() throws {
        throw StorageError.invalidOperation("-removeAll not available in NSManagedObjectContext. Remove the store instead")
    }
    
}

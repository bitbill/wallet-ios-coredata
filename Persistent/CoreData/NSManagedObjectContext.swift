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

extension NSManagedObjectContext: Context {
    
    public func fetch<T>(_ fetchRequest: FetchRequest) throws -> [T] where T : Entity {
        guard let entity = T.self as? NSManagedObject.Type else { throw StorageError.invalidType }
        let request : BBFetchRequest = fetchRequest as! BBFetchRequest
        request.entity = NSEntityDescription.entity(forEntityName: entity.entityName, in: self)
        let results = try self.fetch(fetchRequest as! BBFetchRequest)
        let typedResults = results.map {$0 as! T}
        return typedResults
    }
    
    public func insert<T: Entity>(_ entity: T) throws {}
    
    public func new<T: Entity>() throws -> T {
        guard let entity = T.self as? NSManagedObject.Type else { throw StorageError.invalidType }
        let object = NSEntityDescription.insertNewObject(forEntityName: entity.entityName, into: self)
        if let inserted = object as? T {
            return inserted
        }
        else {
            throw StorageError.invalidType
        }
    }
    
    public func remove<T: Entity>(_ objects: [T]) throws {
        for object in objects {
            guard let object = object as? NSManagedObject else { continue }
            self.delete(object)
        }
    }
    
    public func removeAll() throws {
        throw StorageError.invalidOperation("-removeAll not available in NSManagedObjectContext. Remove the store instead")
    }
    
}

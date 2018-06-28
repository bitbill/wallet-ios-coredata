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
    
    public func fetchModel<T>(_ fetchRequest: FetchRequestProtocol) -> [T] where T : EntityProtocol {
        guard let entity = T.self as? NSManagedObject.Type else { fatalError("fetch is not NSManagedObject") }
        let request : BILFetchRequest = fetchRequest as! BILFetchRequest
        request.entity = NSEntityDescription.entity(forEntityName: entity.entityName, in: self)
        do {
            let results = try self.fetch(request)
            let typedResults = results.map {$0 as! T}
            return typedResults
        } catch {
            return []
        }
    }

    public func newModel<T: EntityProtocol>() -> T {
        guard let entity = T.self as? NSManagedObject.Type else { fatalError("newModel is not NSManagedObject") }
        let object = NSEntityDescription.insertNewObject(forEntityName: entity.entityName, into: self)
        if let inserted = object as? T {
            return inserted
        } else {
            fatalError("newModel insert type is not \(entity.entityName)")
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

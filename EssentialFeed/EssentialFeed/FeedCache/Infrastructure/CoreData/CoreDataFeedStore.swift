//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by David Luna on 27/09/25.
//
import CoreData

public class CoreDataFeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else { throw StoreError.modelNotFound }
        
        do {
            container = try NSPersistentContainer.load(modelName: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentStore(error)
        }
       
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    private func cleanup() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit { cleanup() }
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentStore(Error)
    }
}

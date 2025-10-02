//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by David Luna on 27/09/25.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
    
    public init() {}
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var url: URL
    @NSManaged var descriptionText: String?
    @NSManaged var location: String?
    @NSManaged var cache: ManagedCache
}

//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by David Luna on 03/10/25.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var url: URL
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, imageURL: url)
    }
    
    static func toManaged(_ feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet { 
        return NSOrderedSet(array: feed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.url = local.url
            managed.imageDescription = local.description
            managed.location = local.location
            return managed
        })
    }
}

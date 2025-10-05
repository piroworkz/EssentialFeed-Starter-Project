//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by David Luna on 23/09/25.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
    typealias Result = Swift.Result<Void, Error>
    typealias DeletionCompletion = (Result) -> Void
    typealias InsertionCompletion = (Result) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}

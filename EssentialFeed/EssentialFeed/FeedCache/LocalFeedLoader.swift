//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by David Luna on 23/09/25.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let deleteError = error {
                completion(deleteError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.map {$0.toLocal()}, timestamp: self.currentDate()){ [weak self] insertError in
            guard self != nil else { return }
            completion(insertError)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed, timestamp) where FeedCachePolicy.isCacheValid(timestamp, against: self.currentDate()):
                completion(.success(feed.map { $0.toDomain() }))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        self.store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .found(feed: _, timestamp: timestamp) where !FeedCachePolicy.isCacheValid(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
            case .found, .empty:
                break
            }
        }
        
    }
}

extension LocalFeedImage {
    func toDomain() -> FeedImage {
        return FeedImage(id: id, description: description, location: location, imageURL: url)
    }
}

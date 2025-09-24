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
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    private var maxAgeInDays: Int { return 7 }
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
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
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed, timestamp) where self.isCacheValid(timestamp):
                completion(.success(feed.map { $0.toDomain() }))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.map {$0.toLocal()}, timestamp: self.currentDate()){ [weak self] insertError in
            guard self != nil else { return }
            completion(insertError)
        }
    }
    
    private func isCacheValid(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}


extension LocalFeedImage {
    
    func toDomain() -> FeedImage {
        return FeedImage(id: id, description: description, location: location, imageURL: imageURL)
    }
}

//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by David Luna on 31/10/25.
//
import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.saveIgnoringResult(feed)
                return feed
            })
        }
    }
    
    private func saveIgnoringResult(_ feed: [FeedImage]) {
        cache.save(feed) { _ in  }
    }
}

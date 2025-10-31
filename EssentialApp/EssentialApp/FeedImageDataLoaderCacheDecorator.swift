//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by David Luna on 31/10/25.
//
import Foundation
import EssentialFeed

public class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any EssentialFeed.FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.saveIgnoringResult(data, for: url)
                return data
            })
        }
    }
    
    private func saveIgnoringResult(_ data: Data, for url: URL) {
        cache.save(data, for: url) { _ in }
    }
}

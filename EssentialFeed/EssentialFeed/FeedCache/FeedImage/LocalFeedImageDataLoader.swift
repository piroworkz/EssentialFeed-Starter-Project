//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by David Luna on 29/10/25.
//
import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        let task = Task(completion: completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { _ in .failure(Error.notFound) })
        }
        return task
    }
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private final class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: ((FeedImageDataLoader.Result) -> Void)? = nil) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
        }
    }
    
}

extension LocalFeedImageDataLoader {
    public typealias SaveResult = Swift.Result<Void, Swift.Error>
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url, completion: completion)
    }
}

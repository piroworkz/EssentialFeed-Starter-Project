//
//  FeedImageDataStoreSpy.swift
//  EssentialFeed
//
//  Created by David Luna on 29/10/25.
//
import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private(set) var receivedMessages = [Message]()
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataForURL: url))
        retrievalCompletions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    enum Message: Equatable {
        case retrieve(dataForURL: URL)
        case insert(data: Data, for: URL)
        case failure
    }
}

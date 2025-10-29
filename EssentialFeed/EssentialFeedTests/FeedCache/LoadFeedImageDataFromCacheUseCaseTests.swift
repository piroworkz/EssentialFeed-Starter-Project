//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 28/10/25.
//

import XCTest
import EssentialFeed

final class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = buildSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty, "Expected no messages sent to store upon creation")
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = buildSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataForURL: url)], "Expected to request data for URL from store")
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = buildSUT()
        
        expect(sut, toCompleteWith: failed()) {
            store.completeRetrieval(with: anyNSError())
        }
        
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = buildSUT()
        
        expect(sut, toCompleteWith: notFound()) {
            store.completeRetrieval(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = buildSUT()
        let foundData = anyData()
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        
        store.completeRetrieval(with: foundData)
        store.completeRetrieval(with: anyNSError())
        store.completeRetrieval(with: .none)
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = StoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var received = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { received.append($0) }
        
        sut = nil
        store.completeRetrieval(with: anyData())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after SUT instance has been deallocated")
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = buildSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)], "Expected to request data insertion for URL to store")
    }
}

extension LoadFeedImageDataFromCacheUseCaseTests {
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackMemoryLeak(for: store, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let expectation = expectation(description: "Wait for completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError as LocalFeedImageDataLoader.LoadError), .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            expectation .fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private class StoreSpy: FeedImageDataStore {
        
        private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
        
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
            case insert(data: Data, for: URL)
            case failure
        }
        
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
    }
}

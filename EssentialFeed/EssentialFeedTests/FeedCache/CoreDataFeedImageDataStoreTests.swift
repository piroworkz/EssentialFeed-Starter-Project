//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 29/10/25.
//

import XCTest
import EssentialFeed

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        expect(buildSUT(), toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
}

extension CoreDataFeedImageDataStoreTests {
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeak(for: sut, file: file, line: line)
        return sut
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult,for url: URL, file: StaticString = #filePath, line: UInt = #line) {
        let expecrtation = expectation(description: "Wait for retrieval")
        
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Expected to retrieve \(String(describing: expectedData)) for URL: \(url), got \(String(describing: receivedData)) instead", file: file, line: line)
            default:
                XCTFail("Expected to retrieve \(expectedResult) for URL: \(url), got \(receivedResult) instead", file: file, line: line)
            }
            expecrtation.fulfill()
        }
        wait(for: [expecrtation], timeout: 1.0)
    }
}

extension CoreDataFeedStore: @retroactive FeedImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
    }
    
    
}

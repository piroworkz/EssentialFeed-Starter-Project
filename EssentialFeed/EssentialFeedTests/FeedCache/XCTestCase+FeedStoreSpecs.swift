//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by David Luna on 27/09/25.
//

import XCTest
import Foundation
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let expectation = expectation(description: "Wait for retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(feed: expectedFeed, timestamp: expectedTimestamp), .found(feed: retrievedFeed, timestamp: retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) to match \(retrievedResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let expectation = expectation(description: "Wait for insertion")
        
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedError in
            insertionError = receivedError
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let expectation = expectation(description: "Wait for deletion")
        
        var deletionError : Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        return deletionError
    }
}

//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 24/09/25.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheOnSutCreation(){
        let (_, store) = buildSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = buildSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = buildSUT()
        let retrievalError = anyNSError()
        let expectation = expectation(description: "Wait for load completion")
        
        var receivedError: Error?
        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            expectation.fulfill()
        }
        
        store.completeRetrieval(with: retrievalError)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = buildSUT()
        let expectation = expectation(description: "Wait for load completion")
        
        var receivedImages: [FeedImage]?
        
        sut.load { result in
            switch result {
            case let .success(images):
                receivedImages = images
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            expectation.fulfill()
        }
        
        store.completeRetrievaklWithEmptyCache()
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedImages, [])
    }
}

extension LoadFeedFromCacheUseCaseTests {
    private func buildSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeak(for: store, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any", code: 0)
    }
}

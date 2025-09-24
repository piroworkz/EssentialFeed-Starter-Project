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
        
        sut.load()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
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
}

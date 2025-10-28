//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 28/10/25.
//

import XCTest

final class LocalFeedImageDataLoader {
    
    init(store: Any) {
        
    }

}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = buildSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty, "Expected no messages sent to store upon creation")
    }
}

extension LocalFeedImageDataLoaderTests {
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackMemoryLeak(for: store, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedStoreSpy {
        let receivedMessages = [Any]()
    }
}

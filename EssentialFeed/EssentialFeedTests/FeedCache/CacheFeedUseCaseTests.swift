//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 23/09/25.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed()
    }
}

class FeedStore {
    var deleteCacheFeedCallCount: Int = 0
    
    func deleteCacheFeed() {
        deleteCacheFeedCallCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheOnSutCreation(){
        let (_, store) = buildSUT()
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion(){
        let (sut, store) = buildSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
}


extension CacheFeedUseCaseTests {
    
    private func buildSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "Description", location: "location", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://example.com")!
    }
}

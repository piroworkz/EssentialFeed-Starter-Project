//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 25/09/25.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheOnSutCreation(){
        let (_, store) = buildSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = buildSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = buildSUT()
        
        sut.validateCache()
        store.completeRetrievaklWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    
    func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = buildSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrievalWithFoundCache(feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
}


extension ValidateFeedCacheUseCaseTests {
    
    private func buildSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackMemoryLeak(for: store, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueImageFeed() -> (domain: [FeedImage], local: [LocalFeedImage]) {
        let domain = [uniqueImage(), uniqueImage()]
        let local = domain.map { $0.toLocal() }
        return (domain, local)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any", code: 0)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://example.com")!
    }
}

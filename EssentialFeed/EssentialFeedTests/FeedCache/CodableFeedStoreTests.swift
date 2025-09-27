//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 26/09/25.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = buildSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = buildSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = buildSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = buildSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = buildSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: true, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = buildSUT(storeURL: storeURL)
        
        
        try! "invalid data".write(to: storeURL, atomically: true, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = buildSUT()
        
        let insertionError = insert((uniqueImageFeed().local, timestamp: Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = buildSUT()
        insert((uniqueImageFeed().local, timestamp: Date()), to: sut)
        
        let insertionError = insert((uniqueImageFeed().local, timestamp: Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = buildSUT()
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        
        insert((uniqueImageFeed().local, timestamp: Date()), to: sut)
        insert((latestFeed, timestamp: latestTimestamp), to: sut)

        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = buildSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected to fail insertion")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = buildSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = buildSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected to delete empty cache successfully")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = buildSUT()
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = buildSUT()
        
        insert((uniqueImageFeed().local, timestamp: Date()), to: sut)
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected to delete cache successfully")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = buildSUT()
        
        insert((uniqueImageFeed().local, timestamp: Date()), to: sut)
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletionPermissionURL  = cachesDirectory()
        let sut = buildSUT(storeURL: noDeletionPermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected to fail deletion")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletionPermissionURL  = cachesDirectory()
        let sut = buildSUT(storeURL: noDeletionPermissionURL)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = buildSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let firstOperation = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(firstOperation)
            firstOperation.fulfill()
        }
        
        let secondOperation = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(secondOperation)
            secondOperation.fulfill()
        }
        
        let thirdOperation = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(thirdOperation)
            thirdOperation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [firstOperation, secondOperation, thirdOperation], "Expected side-effects to run serially but operations finished in the wrong order")
    }
}

extension CodableFeedStoreTests {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    private func buildSUT(storeURL: URL? = nil,file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackMemoryLeak(for: sut, file: file, line: line)
        return sut
    }
    

    

    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
}

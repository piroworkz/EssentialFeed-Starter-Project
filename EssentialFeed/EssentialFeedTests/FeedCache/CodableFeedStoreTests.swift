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
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = buildSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = buildSUT()
        
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = buildSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = buildSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: true, encoding: .utf8)
        
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = buildSUT(storeURL: storeURL)
        
        
        try! "invalid data".write(to: storeURL, atomically: true, encoding: .utf8)
        
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = buildSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = buildSUT()
      
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = buildSUT()

        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = buildSUT(storeURL: invalidStoreURL)

        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = buildSUT(storeURL: invalidStoreURL)

        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = buildSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = buildSUT()

        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = buildSUT()

        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = buildSUT()

        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
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

        assertThatSideEffectsRunSerially(on: sut)
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

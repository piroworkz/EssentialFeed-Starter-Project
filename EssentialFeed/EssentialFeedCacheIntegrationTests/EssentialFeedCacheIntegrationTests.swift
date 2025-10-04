//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by David Luna on 03/10/25.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    func test_load_deliversNoItemsOnEmptyCache() throws {
        let sut = try buildSUT()
        let expectation = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch result {
            case let .success(items):
                XCTAssertEqual(items, [], "Expected empty feed")
            case let .failure(error):
                XCTFail("Expected successful load result, got \(error) instead")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() throws {
        let sutToPerformSave = try buildSUT()
        let sutToPerformLoad = try buildSUT()
        let feed = uniqueImageFeed().domain
        let saveExpectation = expectation(description: "Wait for save completion")
        sutToPerformSave.save(feed) { saveResult in
            XCTAssertNil(saveResult, "Expected to save feed successfully")
            saveExpectation.fulfill()
        }
        wait(for: [saveExpectation], timeout: 1.0)
        
        let loadExpectation = expectation(description: "Wait for load completion")
        sutToPerformLoad.load { loadResult in
            switch loadResult {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, feed, "Expected to load feed successfully")
            case let .failure(error):
                XCTFail("Expected successful load result, got \(error) instead")
            }
            loadExpectation.fulfill()
        }
        
        wait(for: [loadExpectation], timeout: 1.0)
    }
}


extension EssentialFeedCacheIntegrationTests {
    
    override func setUp() {
        super.setUp()
        deleteStoreArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        deleteStoreArtifacts()
    }
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) throws -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackMemoryLeak(for: store, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return sut
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}

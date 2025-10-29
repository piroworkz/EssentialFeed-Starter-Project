//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by David Luna on 03/10/25.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    func test_loadFeed_deliversNoItemsOnEmptyCache() throws {
        let feedLoader = try buildFeedLoader()
        
        expect(feedLoader, toLoad: [])
    }
    
    func test_loadFeed_deliversItemsSavedOnASeparateInstance() throws {
        let feedLoaderToPerformSave = try buildFeedLoader()
        let feedLoaderToPerformLoad = try buildFeedLoader()
        let feed = uniqueImageFeed().domain
        
        save(feed, with: feedLoaderToPerformSave)
        
        expect(feedLoaderToPerformLoad, toLoad: feed)
    }
    
    func test_saveFeed_overridesItemsSavedOnASeparateInstance() throws {
        let feedLoaderToPerformFirstSave = try buildFeedLoader()
        let feedLoaderToPerformLastSave = try buildFeedLoader()
        let feedLoaderToPerformLoad = try buildFeedLoader()
        let firstFeed = uniqueImageFeed().domain
        let lastFeed = uniqueImageFeed().domain
        
        save(firstFeed, with: feedLoaderToPerformFirstSave)
        save(lastFeed, with: feedLoaderToPerformLastSave)
        
        expect(feedLoaderToPerformLoad, toLoad: lastFeed)
        
    }
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = try! buildImageLoader()
        let imageLoaderToPerformLoad = try! buildImageLoader()
        let feedLoader = try! buildFeedLoader()
        let image = uniqueImage()
        let dataToSave = anyData()
        
        save([image], with: feedLoader)
        save(dataToSave, for: image.imageURL, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.imageURL)
    }
    
    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() {
        let imageLoaderToPerformFirstSave = try! buildImageLoader()
        let imageLoaderToPerformLastSave = try! buildImageLoader()
        let imageLoaderToPerformLoad = try! buildImageLoader()
        let feedLoader = try! buildFeedLoader()
        let firstDataToSave = anyData()
        let lastDataToSave = anyData()
        let image = uniqueImage()
        
        save([image], with: feedLoader)
        save(firstDataToSave, for: image.imageURL, with: imageLoaderToPerformFirstSave)
        save(lastDataToSave, for: image.imageURL, with: imageLoaderToPerformLastSave)
        
        expect(imageLoaderToPerformLoad, toLoad: lastDataToSave, for: image.imageURL)
    }
    
    func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
        let feedLoaderToPerformSave = try! buildFeedLoader()
        let feedLoaderToPerformValidation = try! buildFeedLoader()
        let feed = uniqueImageFeed().domain
        
        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformValidation, toLoad: feed)
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
    
    private func buildFeedLoader(file: StaticString = #filePath, line: UInt = #line) throws -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackMemoryLeak(for: store, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return sut
    }
    
    private func buildImageLoader(file: StaticString = #filePath, line: UInt = #line) throws -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        trackMemoryLeak(for: store, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
            case let .failure(error):
                XCTFail("Expected successful load result, got \(error) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(loadedData):
                XCTAssertEqual(loadedData, expectedData, "Expected loaded data: \(loadedData) to be equal to saved data: \(expectedData)", file: file, line: line)
            case let .failure(error):
                XCTFail("Expected successful image data load, got \(error) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #filePath, line: UInt = #line) {
        let saveExpectation = expectation(description: "Wait for save completion")
        loader.save(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image data successfully, got error: \(error) instead", file: file, line: line)
            }
            saveExpectation.fulfill()
        }
        wait(for: [saveExpectation], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let saveExpectation = expectation(description: "Wait for save completion")
        loader.save(feed) { saveResult in
            if case let Result.failure(error) = saveResult {
                XCTFail("Expected to save feed successfully, got error: \(error) instead", file: file, line: line)
            }
            saveExpectation.fulfill()
        }
        wait(for: [saveExpectation], timeout: 1.0)
    }
    
    private func validateCache(with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for cache validation")
        
        loader.validateCache { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to validate cache successfully, got error: \(error) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
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

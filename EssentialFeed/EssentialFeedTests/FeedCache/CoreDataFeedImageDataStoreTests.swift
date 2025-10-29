//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 29/10/25.
//

import XCTest
import EssentialFeed

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        expect(buildSUT(), toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = buildSUT()
        let url = anyURL()
        let differentURL = URL(string: "https://different-url.com")!
        
        insert(anyData(), for: differentURL, into: sut)
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: url)
    }
}

extension CoreDataFeedImageDataStoreTests {
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeak(for: sut, file: file, line: line)
        return sut
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult,for url: URL, file: StaticString = #filePath, line: UInt = #line) {
        let expecrtation = expectation(description: "Wait for retrieval")
        
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, "Expected to retrieve \(String(describing: expectedData)) for URL: \(url), got \(String(describing: receivedData)) instead", file: file, line: line)
            default:
                XCTFail("Expected to retrieve \(expectedResult) for URL: \(url), got \(receivedResult) instead", file: file, line: line)
            }
            expecrtation.fulfill()
        }
        wait(for: [expecrtation], timeout: 1.0)
    }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for insertion")
        let image = localImage(url: url)
        
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Expected to insert image data successfully, got error: \(error) instead", file: file, line: line)
            case .success:
                sut.insert(data, for: url) { insertionResult in
                    if case let Result.failure(error) = insertionResult {
                        XCTFail("Expected to insert image data successfully, got error: \(error) instead", file: file, line: line)
                    }
                }
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: nil, location: nil, imageURL: url)
    }
    
}

extension CoreDataFeedStore: @retroactive FeedImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
    }
    
    
}

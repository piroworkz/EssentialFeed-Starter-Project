//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by David Luna on 31/10/25.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [weak self]  result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return task
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        func cancel() { wrapped?.cancel() }
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_, primaryLoader, fallbackLoader) = buildSUT()
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs from fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let (sut, primaryLoader, fallbackLoader) = buildSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load image data from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs from fallback loader")
    }
    
    func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
        let (sut, primaryLoader, fallbackLoader) = buildSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load image data from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load image data from fallback loader on primary loader failure")
    }
    
    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        let (sut, primaryLoader, fallbackLoader) = buildSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancel image data load from primary loader")
        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs from fallback loader")
    }
    
    func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
        let (sut, primaryLoader, fallbackLoader) = buildSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyNSError())
        task.cancel()
        
        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs from primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancel image data load from fallback loader after primary loader failure")
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let (sut, primaryLoader, _) = buildSUT()
        let primaryData = anyData()
        
        expect(sut, toCompleteWith: .success(primaryData)) {
            primaryLoader.complete(with: primaryData)
        }
    }
    
    func test_loadImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
        let (sut, primaryLoader, fallbackLoader) = buildSUT()
        let fallbackData = anyData()
        
        expect(sut, toCompleteWith: .success(fallbackData)) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: fallbackData)
        }
    }
    
    func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let (sut, primaryLoader, fallbackLoader) = buildSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: anyNSError())
        }
    }
}

extension FeedImageDataLoaderWithFallbackCompositeTests {
    
    private func buildSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderWithFallbackComposite, primaryLoader: LoaderSpy, fallbackLoader: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackMemoryLeak(for: primaryLoader, file: file, line: line)
        trackMemoryLeak(for: fallbackLoader, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        action()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        private(set) var cancelledURLs = [URL]()
        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
        
        private struct Task: FeedImageDataLoaderTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
    }
}


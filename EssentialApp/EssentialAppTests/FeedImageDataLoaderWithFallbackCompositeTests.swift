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
        _ = primary.loadImageData(from: url) { [weak self]  result in
            switch result {
            case .success:
                break
            case .failure:
                _ = self?.fallback.loadImageData(from: url) { _ in }
            }
        }
        return Task()
    }
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() { }
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
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() { }
        }
    }
}


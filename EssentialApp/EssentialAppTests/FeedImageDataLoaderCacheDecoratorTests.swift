//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by David Luna on 31/10/25.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any EssentialFeed.FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_, loader) = buildSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URLs on initialization")
    }
    
    func test_loadImageData_loadsFromLoader() {
        let (sut, loader) = buildSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url], "Expected to load image data from loader")
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let (sut, loader) = buildSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel image data load from loader")
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let (sut, loader) = buildSUT()
        let data = anyData()
        
        expect(sut, toCompleteWith: .success(data)) {
            loader.complete(with: data)
        }
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = buildSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            loader.complete(with: anyNSError())
        }
    }
}

extension FeedImageDataLoaderCacheDecoratorTests: FeedImageDataLoaderXCTCase {
    
    private func buildSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loaderSpy: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        trackMemoryLeak(for: loader, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, loader)
    }
    
}


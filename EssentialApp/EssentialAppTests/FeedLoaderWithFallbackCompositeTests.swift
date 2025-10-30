//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by David Luna on 30/10/25.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    
    init(primary: FeedLoader) {
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader)
        let expectation = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, primaryFeed)
            case let .failure(error):
                XCTFail("Expected success, got \(error) instead")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}

extension FeedLoaderWithFallbackCompositeTests {
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", imageURL: URL(string: "http://any-url.com")!)]
    }
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}


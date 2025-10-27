//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 27/10/25.
//

import XCTest

class RemoteFeedImageDataLoader {
    init(client: Any) {
        
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformURLRequests() {
        let (_, client) = buildSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
}

extension RemoteFeedImageDataLoaderTests {
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackMemoryLeak(for: client, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, client)
    }
    
    private class HTTPClientSpy {
        private(set) var requestedURLs = [URL]()
    }
}

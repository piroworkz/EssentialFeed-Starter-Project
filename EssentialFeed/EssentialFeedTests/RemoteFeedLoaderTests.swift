//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 18/09/25.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = buildSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_doesRequestDataFromURL() {
        let url = URL(string: "https://example.com")!
        let (sut, client) = buildSUT(url: url)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    private func buildSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }

}

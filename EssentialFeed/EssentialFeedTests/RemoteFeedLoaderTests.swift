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
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_doesRequestDataFromURL() {
        let url = URL(string: "https://example.com")!
        let (sut, client) = buildSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://example.com")!
        let (sut, client) = buildSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliverErrorOnClientError() {
        let (sut, client) = buildSUT()
        let clientError = NSError(domain: "Test", code: 0)
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0)}
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connection])
    }
    
    func test_load_deliverErrorOnNon200HTTPResponse() {
        let (sut, client) = buildSUT()
        let clientError = NSError(domain: "Test", code: 0)
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0)}
        client.complete(withStatusCode: 400)
        
        XCTAssertEqual(capturedError, [.invalidData])
    }
    
    
    
    private func buildSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)
            messages[index].completion(nil, response)
        }
    }

}

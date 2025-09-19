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
        
        expect(sut, toCompleteWith: .failure(.connection)) {
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliverErrorOnNon200HTTPResponse() {
        let (sut, client) = buildSUT()
        
        [199, 201, 300, 400, 500].enumerated().forEach {index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = buildSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsON200HTTPResponseWithEmptyJSON() {
        let (sut, client) = buildSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = buildItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsON200HTTPResponseWithJSONItems() {
        let (sut, client) = buildSUT()
        
        let item1 = buildFeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = buildFeedItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        let items: [FeedItem] = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            let json = buildItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url: URL = URL(string: "https://example.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0)}
        sut = nil
        client.complete(withStatusCode: 200, data: buildItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
}

extension RemoteFeedLoaderTests {
    
    private func buildSUT(url: URL = URL(string: "https://example.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackMemoryLeak(for: sut, file: file, line: line)
        trackMemoryLeak(for: client, file: file, line: line)
        return (sut, client)
    }
    
    func trackMemoryLeak(for instance: AnyObject,  file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance of SUT must be deallocated after each test", file: file, line: line)
        }
    }
    
    private func buildFeedItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let feedItem = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": feedItem.id.uuidString,
            "description": feedItem.description,
            "location": feedItem.location,
            "image": feedItem.imageURL.absoluteString
        ].reduce(into: [String: Any]()) { accumulated, element in
            if let value = element.value {
                accumulated[element.key] = value
            }
        }
        return (feedItem, json)
    }
    
    private func buildItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = [ "items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line) {
            let expectation = expectation(description: "Wait for load completion")
            
            sut.load { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                case let (.failure(receivedError), .failure(expectedError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                default:
                    XCTFail("Unexpected result: \(receivedResult) <-- does not match --> \(expectedResult)", file: file, line: line)
                }
                expectation.fulfill()
            }
            
            action()
            
            wait(for: [expectation], timeout: 1.0)
        }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}


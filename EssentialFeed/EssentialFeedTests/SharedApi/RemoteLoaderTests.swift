//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeed
//
//  Created by David Luna on 03/11/25.
//



import XCTest
import EssentialFeed

class RemoteLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = buildSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_doesRequestDataFromURL() {
        let url = anyURL()
        let (sut, client) = buildSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = buildSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliverErrorOnClientError() {
        let (sut, client) = buildSUT()
        let clientError = anyNSError()
        
        expect(sut, toCompleteWith: failure(.connection)) {
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnMappedError() {
        let (sut, client) = buildSUT { _, _ in throw anyNSError() }
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversMappedResource() {
        let expected = "any resource"
        let (sut, client) = buildSUT { data , _ in String(data: data, encoding: .utf8)! }
        
        expect(sut, toCompleteWith: .success(expected)) {
            client.complete(withStatusCode: 200, data: Data(expected.utf8))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url: URL = URL(string: "https://example.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client) { _, _ in "any resource" }
        
        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load { capturedResults.append($0)}
        sut = nil
        client.complete(withStatusCode: 200, data: buildItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
}

extension RemoteLoaderTests {
    
    private func buildSUT(
        url: URL = URL(string: "https://example.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any resource" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
            let client = HTTPClientSpy()
            let sut = RemoteLoader(url: url, client: client, mapper: mapper)
            trackMemoryLeak(for: sut, file: file, line: line)
            trackMemoryLeak(for: client, file: file, line: line)
            return (sut, client)
        }
    
    private func buildFeedItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let feedItem = FeedImage(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": feedItem.id.uuidString,
            "description": feedItem.description,
            "location": feedItem.location,
            "image": feedItem.imageURL.absoluteString
        ].compactMapValues { $0 }
        return (feedItem, json)
    }
    
    private func buildItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = [ "items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private func expect(
        _ sut: RemoteLoader<String>,
        toCompleteWith expectedResult: RemoteLoader<String>.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line) {
            let expectation = expectation(description: "Wait for load completion")
            
            sut.load { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                default:
                    XCTFail("Unexpected result: \(receivedResult) <-- does not match --> \(expectedResult)", file: file, line: line)
                }
                expectation.fulfill()
            }
            
            action()
            
            wait(for: [expectation], timeout: 1.0)
        }
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        return .failure(error)
    }
}


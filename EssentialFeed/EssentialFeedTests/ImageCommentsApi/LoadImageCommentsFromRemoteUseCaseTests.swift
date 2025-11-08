//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 18/09/25.
//

import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = buildSUT()
        
        [199, 150, 300, 400, 500].enumerated().forEach {index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = buildSUT()
        let invalidJSON = Data("invalid json".utf8)

        [200, 201, 250, 280, 299].enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: 200, data: invalidJSON, at: index)
            }
        }
    }
    
    func test_load_deliversNoItemsON2xxHTTPResponseWithEmptyJSON() {
        let (sut, client) = buildSUT()
        let emptyListJSON = buildItemsJSON([])
        
        [200, 201, 250, 280, 299].enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([])) {
                client.complete(withStatusCode: 200, data: emptyListJSON, at: index)
            }
        }
    }
    
    func test_load_deliversItemsON2xxHTTPResponseWithJSONItems() {
        let (sut, client) = buildSUT()
        let item1 = buildImageComment(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username")
        
        let item2 = buildImageComment(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username")
        
        let items = [item1.model, item2.model]
        
        [200, 201, 250, 280, 299].enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items)) {
                let json = buildItemsJSON([item1.json, item2.json])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
}

extension LoadImageCommentsFromRemoteUseCaseTests {
    
    private func buildSUT(url: URL = URL(string: "https://example.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        trackMemoryLeak(for: sut, file: file, line: line)
        trackMemoryLeak(for: client, file: file, line: line)
        return (sut, client)
    }
    
    private func buildImageComment(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let imageComment = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        let json: [String : Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
        return (imageComment, json)
    }
    
    private func buildItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = [ "items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private func expect(
        _ sut: RemoteImageCommentsLoader,
        toCompleteWith expectedResult: RemoteImageCommentsLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line) {
            let expectation = expectation(description: "Wait for load completion")
            
            sut.load { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                default:
                    XCTFail("Unexpected result: \(receivedResult) <-- does not match --> \(expectedResult)", file: file, line: line)
                }
                expectation.fulfill()
            }
            
            action()
            
            wait(for: [expectation], timeout: 1.0)
        }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }
}


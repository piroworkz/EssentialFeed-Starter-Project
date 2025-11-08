//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 18/09/25.
//

import XCTest
import EssentialFeed

class ImageCommentMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let emptyListJSON = buildItemsJSON([])
        try [199, 150, 300, 400, 500].forEach { code in
            let expectedResponse = HTTPURLResponse(statusCode: code)
            XCTAssertThrowsError(try ImageCommentMapper.map(emptyListJSON, expectedResponse))
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        
        XCTAssertThrowsError(try ImageCommentMapper.map(invalidJSON, HTTPURLResponse(statusCode: 200)))
    }
    
    func test_map_deliversNoItemsON2xxHTTPResponseWithEmptyJSON() throws {
        let emptyListJSON = buildItemsJSON([])
        
        let actual = try ImageCommentMapper.map(emptyListJSON, HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(actual, [])
    }
    
    func test_map_deliversItemsON2xxHTTPResponseWithJSONItems() throws {
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
        let json = buildItemsJSON([item1.json, item2.json])
        
        try [200, 201, 250, 280, 299].forEach { code in
            let actual = try ImageCommentMapper.map(json, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(actual, items)
        }
    }
    
}

extension ImageCommentMapperTests {
    
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


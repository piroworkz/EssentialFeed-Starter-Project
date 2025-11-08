//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 18/09/25.
//

import XCTest
import EssentialFeed

class FeedImageMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let emptyListJSON = buildItemsJSON([])
        try [199, 201, 300, 400, 500].forEach { code in
            let expectedResponse = HTTPURLResponse(statusCode: code,)
            XCTAssertThrowsError(try FeedImageMapper.map(emptyListJSON, expectedResponse))
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        
        XCTAssertThrowsError(try FeedImageMapper.map(invalidJSON, HTTPURLResponse(statusCode: 200)))
    }
    
    func test_map_deliversNoItemsON200HTTPResponseWithEmptyJSON() throws {
        let emptyListJSON = buildItemsJSON([])

        let actual = try FeedImageMapper.map(emptyListJSON, HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(actual, [])
    }
    
    func test_map_deliversItemsON200HTTPResponseWithJSONItems() throws {
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
        
        let items: [FeedImage] = [item1.model, item2.model]
        let json = buildItemsJSON([item1.json, item2.json])
        
        let actual = try FeedImageMapper.map(json, HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(actual, items)
    }
    
}

extension FeedImageMapperTests {
    
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
}

private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

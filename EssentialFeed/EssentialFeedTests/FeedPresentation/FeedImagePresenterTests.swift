//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 26/10/25.
//

import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsUIState() {
        let expected = uniqueImage()
        let uiState = FeedImagePresenter.map(expected)
        
        XCTAssertEqual(uiState.description, expected.description, "Expected description to be \(String(describing: expected.description))")
        XCTAssertEqual(uiState.location, expected.location, "Expected location to be \(String(describing: expected.location))")
    }
}

//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 21/10/25.
//

import XCTest
import EssentialFeed

final class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, String(localized: .Feed.feedViewTitle), "Expected title to be localized")
    }
    
    func test_map_buildsNewUIState() {
        let feed = uniqueImageFeed().domain
        
        let uiState = FeedPresenter.map(feed)
        
        XCTAssertEqual(uiState.feed, feed, "Expected to map feed to UI state")
    }
}

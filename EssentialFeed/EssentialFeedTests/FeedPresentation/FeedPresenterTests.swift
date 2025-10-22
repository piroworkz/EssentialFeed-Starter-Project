//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 21/10/25.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {
    }
}

final class FeedPresenterTests {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        
        let _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
}

private class ViewSpy {
    let messages = [Any]()
}

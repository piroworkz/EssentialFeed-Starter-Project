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

final class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        
        let _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
}

extension FeedPresenterTests {
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedPresenter {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackMemoryLeak(for: view, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return sut
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}

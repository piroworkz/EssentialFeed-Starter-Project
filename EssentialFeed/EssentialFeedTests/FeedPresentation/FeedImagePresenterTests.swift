//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 26/10/25.
//

import XCTest

class FeedImagePresenter {
    
    init(view: Any) {
        
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = buildSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages sent to view")
    }
}


extension FeedImagePresenterTests {
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackMemoryLeak(for: view, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}

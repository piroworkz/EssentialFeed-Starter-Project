//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 21/10/25.
//

import XCTest

protocol FeedErrorView {
    func display(_ state: FeedErrorViewState)
}

struct FeedErrorViewState {
    let message: String?
    
    static var noError: FeedErrorViewState {
        return FeedErrorViewState(message: nil)
    }
}

final class FeedPresenter {
    private let feedErrorView: FeedErrorView
    
    init(feedErrorView: FeedErrorView) {
        self.feedErrorView = feedErrorView
    }
    
    func didStartLoadingFeed() {
        feedErrorView.display(.noError)
    }
}

final class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = buildSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        let (sut, view) = buildSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(.none)], "Expected no error message when starting to load feed")
    }


}

extension FeedPresenterTests {
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedErrorView: view)
        trackMemoryLeak(for: view, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedErrorView {
        enum Message: Equatable {
            case display(String?)
        }
        var messages = [Message]()
        
        func display(_ state: FeedErrorViewState) {
            messages.append(.display(state.message))
        }
    }
}

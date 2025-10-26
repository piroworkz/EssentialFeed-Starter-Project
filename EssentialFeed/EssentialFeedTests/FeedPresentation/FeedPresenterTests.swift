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

struct FeedLoadingViewState {
    let isLoading: Bool
    
    static var loading: FeedLoadingViewState {
        return FeedLoadingViewState(isLoading: true)
    }
}

protocol FeedLoadingView {
    func display(_ state: FeedLoadingViewState)
}

final class FeedPresenter {
    private let feedErrorView: FeedErrorView
    private let feedLoadingView: FeedLoadingView
    
    init(feedErrorView: FeedErrorView, feedLoadingView: FeedLoadingView) {
        self.feedErrorView = feedErrorView
        self.feedLoadingView = feedLoadingView
    }
    
    func didStartLoadingFeed() {
        feedErrorView.display(.noError)
        feedLoadingView.display(.loading)
    }
}

final class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = buildSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = buildSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(.none), .display(isLoading: true)], "Expected no error message when starting to load feed")
    }
    
    
}

extension FeedPresenterTests {
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedErrorView: view, feedLoadingView: view)
        trackMemoryLeak(for: view, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView {
        enum Message: Equatable {
            case display(String?)
            case display(isLoading: Bool)
        }
        var messages = [Message]()
        
        func display(_ state: FeedErrorViewState) {
            messages.append(.display(state.message))
        }
        
        func display(_ state: FeedLoadingViewState) {
            messages.append(.display(isLoading: state.isLoading))
        }
    }
}

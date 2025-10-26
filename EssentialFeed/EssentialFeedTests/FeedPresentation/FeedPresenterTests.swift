//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 21/10/25.
//

import XCTest
import EssentialFeed

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
    
    static var notLoading: FeedLoadingViewState {
        return FeedLoadingViewState(isLoading: false)
    }
}

protocol FeedLoadingView {
    func display(_ state: FeedLoadingViewState)
}

protocol FeedView {
    func display(_ state: FeedViewState)
}

struct FeedViewState {
    let feed: [FeedImage]
}

final class FeedPresenter {
    private let feedErrorView: FeedErrorView
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    
    init(feedErrorView: FeedErrorView, feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.feedErrorView = feedErrorView
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed() {
        feedErrorView.display(.noError)
        feedLoadingView.display(.loading)
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewState(feed: feed))
        feedLoadingView.display(.notLoading)
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
    
    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = buildSUT()
        let feed = uniqueImageFeed().domain
        
        sut.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [.display(feed: feed), .display(isLoading: false)], "Expected to display feed and stop loading")
    }
}

extension FeedPresenterTests {
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedErrorView: view, feedLoadingView: view, feedView: view)
        trackMemoryLeak(for: view, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        
        enum Message: Hashable {
            case display(String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        var messages = Set<Message>()
        
        func display(_ state: FeedErrorViewState) {
            messages.insert(.display(state.message))
        }
        
        func display(_ state: FeedLoadingViewState) {
            messages.insert(.display(isLoading: state.isLoading))
        }
        
        func display(_ state: FeedViewState) {
            messages.insert(.display(feed: state.feed))
        }
    }
}

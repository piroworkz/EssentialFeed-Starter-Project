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
    
    static func error(message: String) -> FeedErrorViewState {
        return FeedErrorViewState(message: message)
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
    
    private var loadErrorMessage: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the feed")
    }
    
    func didStartLoadingFeed() {
        feedErrorView.display(.noError)
        feedLoadingView.display(.loading)
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewState(feed: feed))
        feedLoadingView.display(.notLoading)
    }
    
    func didFinishLoadingFeed(with error: Error) {
        feedErrorView.display(.error(message: loadErrorMessage))
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
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = buildSUT()
        
        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(localized("FEED_VIEW_CONNECTION_ERROR")), .display(isLoading: false)], "Expected to display localized error message and stop loading")
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
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
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

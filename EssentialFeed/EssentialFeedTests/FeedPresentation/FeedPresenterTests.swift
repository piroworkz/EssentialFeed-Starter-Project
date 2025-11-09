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
        XCTAssertEqual(FeedPresenter.title, FeedPresenter.title)
    }
    
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
        
        XCTAssertEqual(view.messages, [.display(LoadResourcePresenter<String,FakeView>.loadErrorMessage), .display(isLoading: false)], "Expected to display localized error message and stop loading")
    }
}

extension FeedPresenterTests {
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedErrorView: view, feedLoadingView: view as FeedLoadingView, feedView: view as FeedView)
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

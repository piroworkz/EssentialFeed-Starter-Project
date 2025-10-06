//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by David Luna on 05/10/25.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = buildSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.simulateViewAppearing()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view appears")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = buildSUT()
        
        sut.simulateViewAppearing()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view appears")

        loader.completeFeedLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user-initiated reload completes successfully")
    }
}

extension FeedViewControllerTests {
    
    private func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackMemoryLeak(for: sut, file: file, line: line)
        trackMemoryLeak(for: loader, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private var loadCompletions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            return loadCompletions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCompletions.append(completion)
        }
        
        func completeFeedLoading() {
            loadCompletions[0](.success([]))
        }
    }
}

private extension FeedViewController {
    var isShowingLoadingIndicator: Bool {
        return tableView.refreshControl?.isRefreshing == true
    }
    
    func simulateViewAppearing() {
        if !isViewLoaded {
            loadViewIfNeeded()
            setFakeRefreshControl()
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func setFakeRefreshControl() {
        let fakeRefreshControl = FakeRefreshControl()
        refreshControl?.transferActions(to: fakeRefreshControl)
        tableView.refreshControl = fakeRefreshControl
    }
    
    func simulateUserInitiatedFeedReload() {
        tableView.refreshControl?.simulatePullToRefresh()
    }
    
    private class FakeRefreshControl: UIRefreshControl {
        private var _isRefreshing: Bool = false
        
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            super.beginRefreshing()
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            super.endRefreshing()
            _isRefreshing = false
        }
    }
}

private extension UIRefreshControl {
    func transferActions(to fake: UIRefreshControl) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?
                .forEach { action in
                    fake.addTarget(target, action: Selector(action), for: .valueChanged)
                }
        }
    }
    
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?
                .forEach {(target as NSObject).perform(Selector($0))}
        }
    }
}

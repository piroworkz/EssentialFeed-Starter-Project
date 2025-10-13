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
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user-initiated reload completes successfully")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = buildFeedItem(description: "a description", location: "a location")
        let image1 = buildFeedItem(description: nil, location: "another location")
        let image2 = buildFeedItem(description: "another description", location: nil)
        let image3 = buildFeedItem(description: nil, location: nil)
        let (sut, loader) = buildSUT()
        
        sut.simulateViewAppearing()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
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
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor feedImage: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = feedImage.location != nil
        
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected 'isShowingLocation' to be \(shouldLocationBeVisible) for image view at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.locationText, feedImage.location, "Expected location text to be \(String(describing: feedImage.location)) for image view at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, feedImage.description, "Expected description text to be \(String(describing: feedImage.description)) for image view at index \(index)", file: file, line: line)
    }
    
    private func buildFeedItem(description: String? = nil, location: String? = nil, imageURL: URL = URL(string: "https://example.com/image.jpg")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, imageURL: imageURL)
    }
    
    class LoaderSpy: FeedLoader {
        private var loadCompletions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            return loadCompletions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCompletions.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            loadCompletions[index](.success(feed))
        }
    }
}

private extension FeedImageCell {
    
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
}

private extension FeedViewController {
    
    private var feedImagesSection: Int { 0 }
    
    var isShowingLoadingIndicator: Bool {
        return tableView.refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
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

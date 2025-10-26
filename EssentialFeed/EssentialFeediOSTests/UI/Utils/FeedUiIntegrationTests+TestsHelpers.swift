//
//  FeedViewControllerTests+TestsHelpers.swift
//  EssentialFeediOSTests
//
//  Created by David Luna on 16/10/25.
//

import XCTest
import Foundation
import EssentialFeed
import EssentialFeediOS


extension FeedUiIntegrationTests {
    
    func buildSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        trackMemoryLeak(for: sut, file: file, line: line)
        trackMemoryLeak(for: loader, file: file, line: line)
        return (sut, loader)
    }
    
    func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: FeedViewController, hasViewConfiguredFor feedImage: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = feedImage.location != nil
        
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected 'isShowingLocation' to be \(shouldLocationBeVisible) for image view at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.locationText, feedImage.location, "Expected location text to be \(String(describing: feedImage.location)) for image view at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, feedImage.description, "Expected description text to be \(String(describing: feedImage.description)) for image view at index \(index)", file: file, line: line)
    }
    
    func buildFeedItem(description: String? = nil, location: String? = nil, imageURL: URL = URL(string: "https://example.com/image.jpg")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, imageURL: imageURL)
    }
    
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

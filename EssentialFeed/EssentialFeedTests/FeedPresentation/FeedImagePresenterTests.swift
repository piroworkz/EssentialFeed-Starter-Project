//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 26/10/25.
//

import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsUIState() {
        let expected = uniqueImage()
        let uiState = FeedImagePresenter<ViewSpy, AnyImage>.map(expected)
        
        XCTAssertEqual(uiState.description, expected.description, "Expected description to be \(String(describing: expected.description))")
        XCTAssertEqual(uiState.location, expected.location, "Expected location to be \(String(describing: expected.location))")
    }
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = buildSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages sent to view")
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = buildSUT()
        let expected = uniqueImage()
        
        sut.didStartLoadingImageData(for: expected)
        
        let actual = view.messages.first
        XCTAssertEqual(view.messages.count, 1, "Expected one message sent to view")
        XCTAssertEqual(actual?.description, expected.description, "Expected description to be \(String(describing: expected.description))")
        XCTAssertEqual(actual?.location, expected.location, "Expected location to be \(String(describing: expected.location))")
        XCTAssertEqual(actual?.isLoading, true, "Expected isLoading to be true")
        XCTAssertEqual(actual?.shouldRetry, false, "Expected shouldRetry to be false")
        XCTAssertNil(actual?.image, "Expected image to be nil")
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, view) = buildSUT()
        let expected = uniqueImage()
        
        sut.didFinishLoadingImageData(with: Data(), for: expected)
        
        let actual = view.messages.first
        XCTAssertEqual(view.messages.count, 1, "Expected one message sent to view")
        XCTAssertEqual(actual?.isLoading, false, "Expected isLoading to be false")
        XCTAssertEqual(actual?.shouldRetry, true, "Expected shouldRetry to be true")
        XCTAssertNil(actual?.image, "Expected image to be nil")
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let expected = uniqueImage()
        let mappedImage = AnyImage()
        let (sut, view) = buildSUT(imageMapper: { _ in mappedImage })
        
        sut.didFinishLoadingImageData(with: Data(), for: expected)
        
        let actual = view.messages.first
        XCTAssertEqual(view.messages.count, 1, "Expected one message sent to view")
        XCTAssertEqual(actual?.isLoading, false, "Expected isLoading to be false")
        XCTAssertEqual(actual?.shouldRetry, false, "Expected shouldRetry to be false")
        XCTAssertEqual(actual?.image, mappedImage, "Expected image to be the mapped image")
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let expected = uniqueImage()
        let (sut, view) = buildSUT()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: expected)
        
        let actual = view.messages.first
        XCTAssertEqual(view.messages.count, 1, "Expected one message sent to view")
        XCTAssertEqual(actual?.isLoading, false, "Expected isLoading to be false")
        XCTAssertEqual(actual?.shouldRetry, true, "Expected shouldRetry to be true")
        XCTAssertNil(actual?.image, "Expected image to be nil")
    }
}

extension FeedImagePresenterTests {
    
    private var failingImageMapper: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    private func buildSUT(imageMapper: @escaping (Data) -> AnyImage? = { _ in nil }, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageMapper: imageMapper)
        trackMemoryLeak(for: view, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, view)
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageState<AnyImage>]()
        
        func display(_ state: FeedImageState<AnyImage>) {
            messages.append(state)
        }
    }
}

//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 26/10/25.
//

import XCTest
import EssentialFeed

protocol FeedImageView {
    func display(_ state: FeedImageState)
}

struct FeedImageState {
    let description: String?
    let location: String?
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
    
    init(
        description: String? = nil,
        location: String? = nil,
        image: Any? = nil,
        isLoading: Bool = false,
        shouldRetry: Bool = false
    ) {
        self.description = description
        self.location = location
        self.image = image
        self.isLoading = isLoading
        self.shouldRetry = shouldRetry
    }
    
    var hasLocation: Bool {
        return location != nil
    }
    
    func update(
        description: String?? = nil,
        location: String?? = nil,
        image: Any?? = nil,
        isLoading: Bool? = nil,
        shouldRetry: Bool? = nil
    ) -> FeedImageState {
        FeedImageState(
            description: description ?? self.description,
            location: location ?? self.location,
            image: image ?? self.image,
            isLoading: isLoading ?? self.isLoading,
            shouldRetry: shouldRetry ?? self.shouldRetry
        )
    }
}

class FeedImagePresenter {
    
    private let view: FeedImageView
    private let imageMapper: (Data) -> Any?
    
    private var currentState: FeedImageState = FeedImageState()
    
    init(view: FeedImageView, imageMapper: @escaping (Data) -> Any?) {
        self.view = view
        self.imageMapper = imageMapper
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        let state = currentState.update(
            description: model.description,
            location: model.location,
            isLoading: true,
        )
        view.display(state)
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageMapper(data)
        view.display(
            currentState.update(
                image: image,
                isLoading: false,
                shouldRetry: image == nil
            )
        )
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = buildSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages sent to view")
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = buildSUT(imageMapper: {_ in nil})
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
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: expected)
        
        let actual = view.messages.first
        XCTAssertEqual(view.messages.count, 1, "Expected one message sent to view")
        XCTAssertEqual(actual?.isLoading, false, "Expected isLoading to be false")
        XCTAssertEqual(actual?.shouldRetry, true, "Expected shouldRetry to be true")
        XCTAssertNil(actual?.image, "Expected image to be nil")
    }
}


extension FeedImagePresenterTests {
    
    private func buildSUT(imageMapper: @escaping (Data) -> Any? = { _ in nil }, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageMapper: imageMapper)
        trackMemoryLeak(for: view, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageState]()
        
        func display(_ state: FeedImageState) {
            messages.append(state)
        }
    }
}

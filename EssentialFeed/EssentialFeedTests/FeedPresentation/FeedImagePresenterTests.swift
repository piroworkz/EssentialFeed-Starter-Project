//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 26/10/25.
//

import XCTest
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ state: FeedImageState<Image>)
}

struct FeedImageState<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    init(
        description: String? = nil,
        location: String? = nil,
        image: Image? = nil,
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
        image: Image?? = nil,
        isLoading: Bool? = nil,
        shouldRetry: Bool? = nil
    ) -> FeedImageState<Image> {
        FeedImageState(
            description: description ?? self.description,
            location: location ?? self.location,
            image: image ?? self.image,
            isLoading: isLoading ?? self.isLoading,
            shouldRetry: shouldRetry ?? self.shouldRetry
        )
    }
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private let imageMapper: (Data) -> Image?
    
    private var currentState: FeedImageState<Image> = FeedImageState()
    
    init(view: View, imageMapper: @escaping (Data) -> Image?) {
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
        let (sut, view) = buildSUT(imageMapper: failingImageMapper)
        let expected = uniqueImage()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: expected)
        
        let actual = view.messages.first
        XCTAssertEqual(view.messages.count, 1, "Expected one message sent to view")
        XCTAssertEqual(actual?.isLoading, false, "Expected isLoading to be false")
        XCTAssertEqual(actual?.shouldRetry, true, "Expected shouldRetry to be true")
        XCTAssertNil(actual?.image, "Expected image to be nil")
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let expected = uniqueImage()
        let data = Data()
        let mappedImage = AnyImage()
        let (sut, view) = buildSUT(imageMapper: { _ in mappedImage })
        
        sut.didFinishLoadingImageData(with: data, for: expected)
        
        let actual = view.messages.first
        XCTAssertEqual(view.messages.count, 1, "Expected one message sent to view")
        XCTAssertEqual(actual?.isLoading, false, "Expected isLoading to be false")
        XCTAssertEqual(actual?.shouldRetry, false, "Expected shouldRetry to be false")
        XCTAssertEqual(actual?.image, mappedImage, "Expected image to be the mapped image")
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

//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by David Luna on 21/10/25.
//

import XCTest
import EssentialFeed

final class LoadResourcePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = buildSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = buildSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)], "Expected to display no error message and start loading")
    }
    
    func test_didFinishLoadingResource_displaysResourceAndStopsLoading() {
        let (sut, view) = buildSUT(mapper: { resource in resource + " state" })
        
        sut.didFinishLoading(with: "resource")
        
        XCTAssertEqual(view.messages, [.display(state: "resource state"), .display(isLoading: false)], "Expected to display mapped resource and stop loading")
    }
    
    func test_didFinishLoadingWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = buildSUT()
        
        sut.didFinishLoading(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(errorMessage: LoadResourcePresenter<String, FakeView>.loadErrorMessage), .display(isLoading: false)], "Expected to display localized error message and stop loading")
    }
}

extension LoadResourcePresenterTests {
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func buildSUT(
        mapper: @escaping SUT.Mapper = { _ in "" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (SUT, ViewSpy) {
        let view = ViewSpy()
        let sut = SUT(feedErrorView: view, feedLoadingView: view, resourceView: view, mapper: mapper)
        trackMemoryLeak(for: view, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: ErrorMessageView, LoadingView, ResourceView {
        typealias UIState = String
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(state: String)
        }
        var messages = Set<Message>()
        
        func display(_ state: ErrorMessageUIState) {
            messages.insert(.display(errorMessage: state.message))
        }
        
        func display(_ state: LoadingUIState) {
            messages.insert(.display(isLoading: state.isLoading))
        }
        
        func display(_ state: UIState) {
            messages.insert(.display(state: state))
        }
    }
}

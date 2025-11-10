//
//  ImageCommentsPresentation.swift
//  EssentialFeed
//
//  Created by David Luna on 10/11/25.
//
import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, String(localized: .ImageComments.imageCommentsViewTitle), "Expected title to be localized")
    }
}

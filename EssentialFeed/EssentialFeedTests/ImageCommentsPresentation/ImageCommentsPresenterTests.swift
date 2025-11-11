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
    
    func test_map_createsImageCommentUiState() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let comments = [
            ImageComment(id: UUID(), message: "a message", createdAt: now.adding(days: -5), username: "a username"),
            ImageComment(id: UUID(), message: "another message", createdAt: now.adding(days: -1), username: "another username")
        ]
        let expectedComments =  [
            CommentUiState(message: "a message", date: "5 days ago", username: "a username"),
            CommentUiState(message: "another message", date: "1 day ago", username: "another username")
        ]
        
        let actualComments = ImageCommentsPresenter.map(comments: comments, calendar: calendar, locale: Locale(identifier: "en_US_POSIX"), date: now).comments
        
        XCTAssertEqual(actualComments, expectedComments)
    }
}

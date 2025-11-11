//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by David Luna on 10/11/25.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        return String(localized: .ImageComments.imageCommentsViewTitle)
    }
    
    public static func map(
        comments: [ImageComment],
        calendar: Calendar = .current,
        locale: Locale = .current,
        date now: Date = Date()) -> ImageCommentsUiState {
        let formatter = RelativeDateTimeFormatter()
        let mapped = comments.map{ coment in
            Comment(
                message: coment.message,
                date: formatter.localizedString(for: coment.createdAt, relativeTo: now),
                username: coment.username)
        }
        return ImageCommentsUiState(comments: mapped)
    }
}

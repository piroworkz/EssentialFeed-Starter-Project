//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//

import Foundation

public final class FeedPresenter {
    
    public static var title: String {
        return String(localized: .Feed.feedViewTitle)
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewState {
        return FeedViewState(feed: feed)
    }
}

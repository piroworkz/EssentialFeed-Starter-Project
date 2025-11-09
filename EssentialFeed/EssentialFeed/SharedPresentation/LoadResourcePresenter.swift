//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by David Luna on 09/11/25.
//

import Foundation

public class LoadResourcePresenter {
    private let feedErrorView: FeedErrorView
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    
    public init(feedErrorView: FeedErrorView, feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.feedErrorView = feedErrorView
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Feed view title")
    }
    
    private var loadErrorMessage: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the feed")
    }
    
    public func didStartLoadingFeed() {
        feedErrorView.display(.noError)
        feedLoadingView.display(.loading)
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewState(feed: feed))
        feedLoadingView.display(.notLoading)
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        feedErrorView.display(.error(message: loadErrorMessage))
        feedLoadingView.display(.notLoading)
    }
}

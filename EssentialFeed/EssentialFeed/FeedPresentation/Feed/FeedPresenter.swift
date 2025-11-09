//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//

import Foundation

public final class FeedPresenter {
    private let feedErrorView: ErrorMessageView
    private let feedLoadingView: LoadingView
    private let feedView: FeedView
    
    public init(feedErrorView: ErrorMessageView, feedLoadingView: LoadingView, feedView: FeedView) {
        self.feedErrorView = feedErrorView
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    public static var title: String {
        return String(localized: .Feed.feedViewTitle)
    }
    
    private var loadErrorMessage: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR", tableName: "Shared", bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the feed")
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

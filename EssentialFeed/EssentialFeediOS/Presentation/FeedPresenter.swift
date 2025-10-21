//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewState {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ state: FeedLoadingViewState)
}

struct FeedViewState {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ state: FeedViewState)
}

struct FeedErrorViewState {
    let message: String?
}

protocol FeedErrorView {
    func display(_ state: FeedErrorViewState)
}

final class FeedPresenter {
    
    private let feedView: FeedView
    private let feedLoadingView: FeedLoadingView
    private let feedErrorView: FeedErrorView
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Feed view title")
    }
    
    private var loadErrorMessage: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the feed")
    }
    
    init(feedView: FeedView, feedLoadingView: FeedLoadingView, feedErrorView: FeedErrorView) {
        self.feedView = feedView
        self.feedLoadingView = feedLoadingView
        self.feedErrorView = feedErrorView
    }
    
    func didStartLoadingFeed() {
        feedErrorView.display(FeedErrorViewState(message: nil))
        feedLoadingView.display(FeedLoadingViewState(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewState(feed: feed))
        feedLoadingView.display(FeedLoadingViewState(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        feedErrorView.display(FeedErrorViewState(message: loadErrorMessage))
        feedLoadingView.display(FeedLoadingViewState(isLoading: false))
    }
    
    
}

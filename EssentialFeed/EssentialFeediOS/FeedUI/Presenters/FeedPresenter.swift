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

final class FeedPresenter {
    
    private let feedView: FeedView
    private let feedLoadingView: FeedLoadingView
    
    init(feedView: FeedView, feedLoadingView: FeedLoadingView) {
        self.feedView = feedView
        self.feedLoadingView = feedLoadingView
    }
    
    func didStartLoadingFeed() {
        feedLoadingView.display(FeedLoadingViewState(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewState(feed: feed))
        feedLoadingView.display(FeedLoadingViewState(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        feedLoadingView.display(FeedLoadingViewState(isLoading: false))
    }
    
    
}

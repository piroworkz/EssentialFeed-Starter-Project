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
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var feedLoadingView: FeedLoadingView?
    
    func loadFeed() {
        feedLoadingView?.display(FeedLoadingViewState(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewState(feed: feed))
            }
            self?.feedLoadingView?.display(FeedLoadingViewState(isLoading: false))
        }
    }
    
}

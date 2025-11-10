//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by David Luna on 18/10/25.
//
import Combine
import EssentialFeed
import EssentialFeediOS

final class CommonPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> LocalFeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: CommonPresenter<[FeedImage], FeedViewAdapter>?
    
    init(feedLoader: @escaping () -> LocalFeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        cancellable = feedLoader().sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                }
                self?.cancellable = nil
            },
            receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoading(with: feed)
                self?.cancellable = nil
            })
    }
}

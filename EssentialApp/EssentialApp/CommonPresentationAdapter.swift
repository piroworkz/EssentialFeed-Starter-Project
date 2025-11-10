//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by David Luna on 18/10/25.
//
import Combine
import Foundation
import EssentialFeed
import EssentialFeediOS

final class CommonPresentationAdapter<T, View: CommonView> {
    private let loader: () -> AnyPublisher<T, Error>
    private var cancellable: Cancellable?
    var presenter: CommonPresenter<T, View>?
    
    init(loader: @escaping () -> AnyPublisher<T, Error>) {
        self.loader = loader
    }
    
    func load() {
        presenter?.didStartLoading()
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                    self?.cancellable = nil
                },
                receiveValue: { [weak self] value in
                    self?.presenter?.didFinishLoading(with: value)
                    self?.cancellable = nil
                })
    }
}

extension CommonPresentationAdapter: FeedViewControllerDelegate {
    func didRequestFeedRefresh() {
        load()
    }
}

extension CommonPresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        load()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}

//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter()
        let presenterAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: presenter)
        let refreshController = FeedRefreshViewController(delegate: presenterAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        presenter.feedLoadingView = WeakReference(refreshController)
        presenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(viewModel: FeedImageViewModel<UIImage>(model: model, imageLoader: loader, mapImage: UIImage.init))
            }
        }
    }
    
}

private final class WeakReference<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T) {
        self.value = value
    }
}

extension WeakReference: FeedLoadingView where T: FeedLoadingView {
    func display(_ state: FeedLoadingViewState) {
        value?.display(state)
    }
}


private class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ state: FeedViewState) {
        controller?.tableModel = state.feed.map { model in
            FeedImageCellController(viewModel: FeedImageViewModel<UIImage>(model: model, imageLoader: loader, mapImage: UIImage.init))
        }
    }
}


private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter
    
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}

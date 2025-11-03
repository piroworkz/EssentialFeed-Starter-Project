//
//  FeedViewAdapter.swift
//  EssentialFeed
//
//  Created by David Luna on 18/10/25.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, feedImageDataLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.loader = feedImageDataLoader
    }
    
    func display(_ state: FeedViewState) {
        controller?.display(state.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakReference<FeedImageCellController>, UIImage>(model: model, imageLoader: loader)
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(
                view: WeakReference(view),
                imageMapper: UIImage.init
            )
            return view
        })
    }
}

//
//  FeedViewAdapter.swift
//  EssentialFeed
//
//  Created by David Luna on 18/10/25.
//

import UIKit
import EssentialFeed

final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ state: FeedViewState) {
        controller?.tableModel = state.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakReference<FeedImageCellController>, UIImage>(model: model, imageLoader: loader)
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(
                view: WeakReference(view),
                imageMapper: UIImage.init
            )
            
            return view
        }
    }
}

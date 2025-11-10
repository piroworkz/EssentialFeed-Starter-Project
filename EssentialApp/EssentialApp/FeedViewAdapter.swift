//
//  FeedViewAdapter.swift
//  EssentialFeed
//
//  Created by David Luna on 18/10/25.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: CommonView {
    
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ state: FeedViewState) {
        controller?.display(state.feed.map { model in
            let adapter = CommonPresentationAdapter<Data, WeakReference<FeedImageCellController>>(loader: { [imageLoader] in imageLoader(model.imageURL) })
            let view = FeedImageCellController(state: FeedImagePresenter.map(model), delegate: adapter)
            
            adapter.presenter = CommonPresenter(
                errorView: WeakReference(view),
                loadingView: WeakReference(view),
                view: WeakReference(view),
                mapper: { data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageDataError()
                    }
                    return image
                })
            return view
        })
    }
    private struct InvalidImageDataError: Error {}
}


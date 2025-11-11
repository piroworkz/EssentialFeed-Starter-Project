//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(loader: @escaping () -> LocalFeedLoader.Publisher, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
        
        let presenterAdapter = CommonPresentationAdapter<[FeedImage], FeedViewAdapter>(loader: loader)
        let feedController = makeWith(title: FeedPresenter.title)
        feedController.onRefresh = presenterAdapter.load
        
        presenterAdapter.presenter = CommonPresenter(
            errorView: WeakReference(feedController),
            loadingView: WeakReference(feedController),
            view: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
            mapper: FeedPresenter.map
        )
        
        return feedController
    }
    
    private static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = FeedPresenter.title
        return feedController
    }
}


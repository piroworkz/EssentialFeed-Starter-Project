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
        let presenterAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        let feedController = makeWith(
            delegate: presenterAdapter,
            title: FeedPresenter.title
        )
        
        presenterAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, loader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            feedLoadingView: WeakReference(feedController),
            feedErrorView: WeakReference(feedController)
        )
        
        return feedController
    }
    
    private static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = FeedPresenter.title
        return feedController
    }
}


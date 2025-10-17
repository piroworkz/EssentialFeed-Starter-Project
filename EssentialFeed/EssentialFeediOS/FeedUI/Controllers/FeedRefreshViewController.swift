//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import UIKit

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private let delegate: FeedRefreshViewControllerDelegate
    
    public lazy var view: UIRefreshControl = loadView()
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }

    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(_ state: FeedLoadingViewState) {
        if state.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

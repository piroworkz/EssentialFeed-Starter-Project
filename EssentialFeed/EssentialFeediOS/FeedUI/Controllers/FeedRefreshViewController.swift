//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import UIKit

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    var delegate: FeedRefreshViewControllerDelegate?
    @IBOutlet public var view: UIRefreshControl?

    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ state: FeedLoadingViewState) {
        if state.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

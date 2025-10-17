//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
    
    private let viewModel: FeedViewModel
    
    public lazy var view: UIRefreshControl = bind(UIRefreshControl())
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    func bind(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

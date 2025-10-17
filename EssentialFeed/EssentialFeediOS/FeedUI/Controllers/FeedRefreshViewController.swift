//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import UIKit

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private let presenter: FeedPresenter
    
    public lazy var view: UIRefreshControl = loadView()
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }

    @objc func refresh() {
        presenter.loadFeed()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
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

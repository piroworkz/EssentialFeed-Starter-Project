//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by David Luna on 05/10/25.
//

import UIKit
import EssentialFeed

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {
    @IBOutlet private(set) public var errorView: ErrorView?
    private var onFirstViewIsAppearing: ((FeedViewController) -> Void)?
    var delegate : FeedViewControllerDelegate?
    var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        onFirstViewIsAppearing = { controller in
            controller.onFirstViewIsAppearing = nil
            controller.refresh()
        }
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public func display(_ state: FeedLoadingViewState) {
        refreshControl?.update(isRefreshing: state.isLoading)
    }
    
    public func display(_ viewModel: FeedErrorViewState) {
        errorView?.message = viewModel.message
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewWillAppear(animated)
        onFirstViewIsAppearing?(self)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
}



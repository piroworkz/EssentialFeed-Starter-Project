//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by David Luna on 05/10/25.
//
import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var onFirstViewIsAppearing: ((FeedViewController) -> Void)?
    private var tableModel = [FeedImage]()
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        onFirstViewIsAppearing = { controller in
            controller.load()
            controller.onFirstViewIsAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewWillAppear(animated)
        onFirstViewIsAppearing?(self)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.descriptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        cell.locationContainer.isHidden = cellModel.location == nil
        return cell
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            
            switch result {
            case let .success(feed):
                self?.tableModel = feed
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            case .failure: break
            }
        }
    }
}

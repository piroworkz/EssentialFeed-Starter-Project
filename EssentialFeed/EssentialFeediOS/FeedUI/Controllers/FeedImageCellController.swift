//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    func display(_ state: FeedImageState<UIImage>) {
        cell?.locationContainer.isHidden = !state.hasLocation
        cell?.locationLabel.text = state.location
        cell?.descriptionLabel.text = state.description
        cell?.feedImageView.image = state.image
        cell?.feedImageContainer.isShimmering = state.isLoading
        cell?.feedImageRetryButton.isHidden = !state.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}


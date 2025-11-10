//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by David Luna on 16/10/25.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: CommonView, LoadingView, ErrorMessageView {
    public typealias UIState = UIImage
    
    private let state: FeedImageState
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    public init(state: FeedImageState, delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
        self.state = state
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer?.isHidden = !state.hasLocation
        cell?.locationLabel?.text = state.location
        cell?.descriptionLabel?.text = state.description
        cell?.onRetry = delegate.didRequestImage
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
    
    public func display(_ state: UIImage) {
        cell?.feedImageView?.setImageAnimated(state)
    }
    
    public func display(_ state: EssentialFeed.LoadingUIState) {
        cell?.feedImageContainer?.isShimmering = state.isLoading
    }
    
    public func display(_ state: EssentialFeed.ErrorMessageUIState) {
        cell?.feedImageRetryButton?.isHidden = state.message == nil
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

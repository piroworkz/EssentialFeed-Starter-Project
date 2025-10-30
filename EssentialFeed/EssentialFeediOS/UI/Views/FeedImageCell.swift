//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by David Luna on 13/10/25.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    
    @IBOutlet private(set) public var locationContainer: UIView?
    @IBOutlet private(set) public var locationLabel: UILabel?
    @IBOutlet private(set) public var descriptionLabel: UILabel?
    @IBOutlet private(set) public var feedImageContainer: UIView?
    @IBOutlet private(set) public var feedImageView: UIImageView?
    @IBOutlet private(set) public var feedImageRetryButton: UIButton?
    
    var onRetry: (() -> Void)?
    
    @IBAction
    private func retryButtonTapped() {
        onRetry?()
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        locationContainer?.isHidden = true
        locationLabel?.text = nil
        descriptionLabel?.text = nil
        feedImageContainer?.isHidden = false
        feedImageRetryButton?.isHidden = true
        feedImageView?.image = nil
    }
}

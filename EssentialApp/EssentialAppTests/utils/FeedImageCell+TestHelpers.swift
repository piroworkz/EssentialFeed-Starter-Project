//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by David Luna on 16/10/25.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
    
    var isShowingLocation: Bool {
        return !(locationContainer?.isHidden ?? false)
    }
    
    var locationText: String? {
        return locationLabel?.text
    }
    
    var descriptionText: String? {
        return descriptionLabel?.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer?.isShimmering ?? false
    }
    
    var renderedImage: Data? {
        return feedImageView?.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        return !(feedImageRetryButton?.isHidden ?? false)
    }
    
    func simulateRetryAction() {
        feedImageRetryButton?.simulateTap()
    }
}

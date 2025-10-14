//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by David Luna on 13/10/25.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc
    private func retryButtonTapped() {
        onRetry?()
    }
}

extension UIView {
    private var shimmerAnimationKey: String { "shimmerAnimation" }
    public var isShimmering: Bool {
        return layer.mask?.animation(forKey: shimmerAnimationKey) != nil
    }
    
    func startShimmering() {
        let white = UIColor.white.cgColor
                let alpha = UIColor.white.withAlphaComponent(0.75).cgColor
                let width = bounds.width
                let height = bounds.height

                let gradient = CAGradientLayer()
                gradient.colors = [alpha, white, alpha]
                gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
                gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
                gradient.locations = [0.4, 0.5, 0.6]
                gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
                layer.mask = gradient

                let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
                animation.fromValue = [0.0, 0.1, 0.2]
                animation.toValue = [0.8, 0.9, 1.0]
                animation.duration = 1.25
                animation.repeatCount = .infinity
                gradient.add(animation, forKey: shimmerAnimationKey)
    }
    
    func stopShimmering() {
        layer.mask = nil
    }
    
}

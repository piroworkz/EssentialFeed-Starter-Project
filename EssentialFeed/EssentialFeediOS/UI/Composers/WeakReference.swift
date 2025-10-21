//
//  WeakReference.swift
//  EssentialFeed
//
//  Created by David Luna on 18/10/25.
//

import UIKit

final class WeakReference<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T) {
        self.value = value
    }
}

extension WeakReference: FeedLoadingView where T: FeedLoadingView {
    func display(_ state: FeedLoadingViewState) {
        value?.display(state)
    }
}

extension WeakReference: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ state: FeedImageState<UIImage>) {
        value?.display(state)
    }
}

extension WeakReference: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewState) {
        value?.display(viewModel)
    }
}

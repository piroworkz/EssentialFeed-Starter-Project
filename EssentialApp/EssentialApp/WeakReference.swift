//
//  WeakReference.swift
//  EssentialFeed
//
//  Created by David Luna on 18/10/25.
//

import UIKit
import EssentialFeed

final class WeakReference<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T) {
        self.value = value
    }
}

extension WeakReference: LoadingView where T: LoadingView {
    func display(_ state: LoadingUIState) {
        value?.display(state)
    }
}

extension WeakReference: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ state: FeedImageState<UIImage>) {
        value?.display(state)
    }
}

extension WeakReference: ErrorMessageView where T: ErrorMessageView {
    func display(_ state: ErrorMessageUIState) {
        value?.display(state)
    }
}

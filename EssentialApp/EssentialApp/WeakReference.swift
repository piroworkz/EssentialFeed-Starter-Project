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

extension WeakReference: CommonView where T: CommonView, T.UIState == UIImage {
    func display(_ state: UIImage) {
        value?.display(state)
    }
}

extension WeakReference: ErrorMessageView where T: ErrorMessageView {
    func display(_ state: ErrorMessageUIState) {
        value?.display(state)
    }
}

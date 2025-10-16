//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by David Luna on 16/10/25.
//

import UIKit

extension UIRefreshControl {
    func transferActions(to fake: UIRefreshControl) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?
                .forEach { action in
                    fake.addTarget(target, action: Selector(action), for: .valueChanged)
                }
        }
    }
    
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}

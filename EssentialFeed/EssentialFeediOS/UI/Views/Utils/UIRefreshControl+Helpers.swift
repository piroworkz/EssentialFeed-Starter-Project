//
//  UIRefreshControl+Helpers.swift
//  EssentialFeed
//
//  Created by David Luna on 21/10/25.
//
import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}

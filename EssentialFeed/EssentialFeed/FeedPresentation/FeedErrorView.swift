//
//  FeedErrorView.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//

import Foundation

public protocol FeedErrorView {
    func display(_ state: FeedErrorViewState)
}

//
//  FeedImageView.swift
//  EssentialFeed
//
//  Created by David Luna on 26/10/25.
//


public protocol FeedImageView {
    associatedtype Image
    func display(_ state: FeedImageState<Image>)
}

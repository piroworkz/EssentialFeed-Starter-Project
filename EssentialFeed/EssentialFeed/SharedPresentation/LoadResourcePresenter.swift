//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by David Luna on 09/11/25.
//

import Foundation

public protocol ResourceView {
    associatedtype UIState
    func display(_ state: UIState)
}

public class LoadResourcePresenter<T, View: ResourceView> {
    public typealias Mapper = (T) -> View.UIState
    private let feedErrorView: FeedErrorView
    private let feedLoadingView: FeedLoadingView
    private let resourceView: View
    private let mapper: Mapper
    
    public init(feedErrorView: FeedErrorView, feedLoadingView: FeedLoadingView, resourceView: View, mapper: @escaping Mapper) {
        self.feedErrorView = feedErrorView
        self.feedLoadingView = feedLoadingView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    
    public static var loadErrorMessage: String {
        return String(localized: .Shared.genericConnectionError)
    }
    
    public func didStartLoading() {
        feedErrorView.display(.noError)
        feedLoadingView.display(.loading)
    }
    
    public func didFinishLoading(with resource: T) {
        resourceView.display(mapper(resource))
        feedLoadingView.display(.notLoading)
    }
    
    public func didFinishLoading(with error: Error) {
        feedErrorView.display(.error(message: Self.loadErrorMessage))
        feedLoadingView.display(.notLoading)
    }
}
